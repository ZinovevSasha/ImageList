//
//  UnsplashRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 06.03.2023.
//

import Foundation

protocol UnsplashRequestProtocol {
    func getMe() -> URLRequest
    func userPortfolio(username: String) -> URLRequest
    func photos(page: Int) -> URLRequest
    func like(photoId: String, isLiked: Bool) -> URLRequest
}

struct UnsplashRequest {
    // MARK: - Dependency
    private let authTokenStorage: OAuth2TokenStorage
    
    // MARK: - Init (Dependency injection)
    init(authTokenStorage: OAuth2TokenStorage) {
        self.authTokenStorage = authTokenStorage
    }
    
    private var token: String {
        if let token = OAuth2TokenStorage().token {
            return token
        } else {
            preconditionFailure("Something wrong")
        }
    }
    
    private var host: String {
        "api.unsplash.com"
    }
    
    private func createRequest(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        httpMethod: HTTPMethod = .get
    ) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            host: host,
            path: path,
            queryItems: queryItems,
            httpMethod: httpMethod
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension UnsplashRequest: UnsplashRequestProtocol {
    func getMe() -> URLRequest {
        createRequest(path: "/me")
    }
    
    func userPortfolio(username: String) -> URLRequest {
        createRequest(path: "/users/\(username)")
    }
    
    func photos(page: Int) -> URLRequest {
        createRequest(
            path: "/photos",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "10"),
                URLQueryItem(name: "order_by", value: "latest")
            ]
        )
    }
    
    func like(photoId: String, isLiked: Bool) -> URLRequest {
        let method = isLiked ? HTTPMethod.delete : .post
        return createRequest(path: "/photos/\(photoId)/like", httpMethod: method)
    }
}
