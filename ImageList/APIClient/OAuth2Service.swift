//
//  OAuth2Service.swift
//  ImageList
//
//  Created by Александр Зиновьев on 26.01.2023.
//

import Foundation

final class OAuth2Service: OAuth2ServiceProtocol {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    
    private enum ServiceError: Error {
        case failedToCreateRequest
    }
    
    public func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = authTokenRequest(code: code) else {
            completion(.failure(ServiceError.failedToCreateRequest))
            return
        }
        
        let task = object(for: request) { result in
            switch result {
            case .success(let body):
                completion(.success(body.access_token))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return urlSession.data(for: request) { result in
            let response = result
                .flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                    Result { try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data) }
                }
            completion(response)
        }
    }
    
    private func authTokenRequest(code: String) -> URLRequest? {
        return URLRequest.makeHTTPRequest(
            path: "/oauth/token",
            queryItems: [
                URLQueryItem(name: "client_id", value: accessKey),
                URLQueryItem(name: "client_secret", value: secretKey),
                URLQueryItem(name: "redirect_uri", value: redirectURI),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "grant_type", value: "authorization_code")
            ],
            httpMethod: "POST"
        )
    }
    
    private struct OAuthTokenResponseBody: Codable {
        let access_token: String
        let token_type: String
        let scope: String
        let created_at: Int
    }
}
