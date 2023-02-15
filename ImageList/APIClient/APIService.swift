//
//  UniversalServise.swift
//  ImageList
//
//  Created by Александр Зиновьев on 13.02.2023.
//

import Foundation

protocol APIServiceProtocol {
    func fetch<T: Decodable>(
        request: UnsplashRequests,
        expectedType type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    )
}

final class APIService: APIServiceProtocol {
    private var task: URLSessionTask?
    
    func fetch<T: Decodable>(
        request: UnsplashRequests,
        expectedType type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        assert(Thread.isMainThread, "Thread.isMainThread")
        task?.cancel()

        let task = URLSession.shared.objectTask(
            for: request.request,
            expected: type) { result in
                switch result {
                case .success(let body):
                    completion(.success(body))
                    self.task = nil
                case .failure(let error):
                    completion(.failure(error))
                    self.task = nil
                }
        }
        self.task = task
        task.resume()
    }
}
