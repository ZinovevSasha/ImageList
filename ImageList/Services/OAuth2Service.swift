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

final class OAuth2Service {
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
}

extension OAuth2Service: OAuth2ServiceProtocol {
    func fetchOAuthToken(
        withCode code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        apiService.fetch(
            request: .oAuthToken(code: code),
            expectedType: OAuthTokenResponseBody.self
        ) { result in
            switch result {
            case .success(let success):
                completion(.success(success.accessToken))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
    }
}
