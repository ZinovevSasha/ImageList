//
//  URLSessionNetworkLayer.swift
//  ImageList
//
//  Created by Александр Зиновьев on 07.03.2023.
//

import Foundation

protocol NetworkLayer {
    func object<T: Decodable>(
        for request: URLRequest,
        expectedType type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask
}

final class URLSessionNetworkLayer: NetworkLayer {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
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
        
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data,
                let response = response,
                let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let decodedData = try self.decoder.decode(type, from: data)
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
        return task
    }
    
    private enum Errors: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
        case decodingError(Error)
    }
}
