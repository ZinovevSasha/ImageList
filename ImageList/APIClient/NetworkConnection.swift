//
//  NetworkConnection.swift
//  ImageList
//
//  Created by Александр Зиновьев on 31.01.2023.
//

import Foundation

extension URLSession {
    static let sharedDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private enum Errors: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
        case decodingError(Error)
    }
    
    func object<T: Decodable>(
        for request: URLRequest,
        expectedType type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
                let response = response,
                let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decodedData = try Self.sharedDecoder.decode(type, from: data)
                        fulfillCompletion(.success(decodedData))
                    } catch {
                        fulfillCompletion(.failure(Errors.decodingError(error)))
                    }
                } else {
                    fulfillCompletion(.failure(Errors.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(Errors.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(Errors.urlSessionError))
            }
        }
        task.resume()
        return task
    }
}
