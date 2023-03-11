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
    private let authTokenStorage: OAuth2TokenStorageProtocol
    private let configuration: AuthConfigurationProtocol
    private let requestBuilder: RequestBuilding
    
    // MARK: - Init (Dependency injection)
    init(
        configuration: AuthConfigurationProtocol = UnsplashAuthConfiguration.standard,
        authTokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage(),
        requestBuilder: RequestBuilding = RequestBuilder()
    ) {
        self.configuration = configuration
        self.authTokenStorage = authTokenStorage
        self.requestBuilder = requestBuilder
    }
    
    private var token: String {
        if let token = OAuth2TokenStorage().token {
            return token
        } else {
            preconditionFailure("Something wrong")
        }
    }
    
    private func createRequest(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        httpMethod: HTTPMethod = .get
    ) -> URLRequest {
        var request = requestBuilder.makeHTTPRequest(
            host: configuration.defaultBaseHost,
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
