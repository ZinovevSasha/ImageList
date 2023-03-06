//
//  OAuth2Service.swift
//  ImageList
//
//  Created by Александр Зиновьев on 26.01.2023.
//

import Foundation

protocol OAuth2ServiceProtocol {
    func fetchOAuthToken(
        withCode code: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
}

final class OAuth2Service: OAuth2ServiceProtocol {
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private let authHelper: UnsplashAuthTokenRequestProtocol
    
    init(authHelper: UnsplashAuthTokenRequestProtocol) {
        self.authHelper = authHelper
    }
    
    func fetchOAuthToken(
        withCode code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = authHelper.oAuthToken(code: code)
        let task = urlSession.object(
            for: request,
            expectedType: OAuthTokenResponseBody.self
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
            self.lastCode = nil
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
    }
}
