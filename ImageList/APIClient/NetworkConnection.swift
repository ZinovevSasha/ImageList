//
//  NetworkConnection.swift
//  ImageList
//
//  Created by Александр Зиновьев on 31.01.2023.
//

import Foundation

private enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError(Error)
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        expected type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask {
        let fulfillCompletion: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
       
        let task = dataTask(with: request) { data, response, error -> Void in
            if let data = data,
                let response = response,
                let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200..<300 ~= statusCode {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let objectOfMyType = try decoder.decode(type, from: data)
                        fulfillCompletion(.success(objectOfMyType))
                    } catch {
                        fulfillCompletion(.failure(NetworkError.parsingError(error)))
                    }
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        }
        task.resume()
        return task
    }
}
