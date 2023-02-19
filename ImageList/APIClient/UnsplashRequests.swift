//
//  UnsplashRequests.swift
//  ImageList
//
//  Created by Александр Зиновьев on 12.02.2023.
//

import Foundation

enum UnsplashRequests {
    case authentication
    case oAuthToken(code: String)
    case getMe
    case userPortfolio(username: String)
    case photos(page: Int)
}

extension UnsplashRequests {
    private var token: String {
        guard let token = OAuth2TokenStorage().token else {
            return "No Token"
        }
        return token
    }
    
    var request: URLRequest {
        switch self {
        case .getMe:
            var request = URLRequest.makeHTTPRequest(path: "/me")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            // "https://api.unsplash.com/me"
            return request
        
        case .userPortfolio(let username):
            var request = URLRequest.makeHTTPRequest(path: "/users/\(username)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            // "https://api.unsplash.com/users/\(username)"
            return request
        
        case .oAuthToken(let code):
            return URLRequest.makeHTTPRequest(
                host: "unsplash.com",
                path: "/oauth/token",
                queryItems: [
                    URLQueryItem(name: "client_id", value: accessKey),
                    URLQueryItem(name: "client_secret", value: secretKey),
                    URLQueryItem(name: "redirect_uri", value: redirectURI),
                    URLQueryItem(name: "code", value: code),
                    URLQueryItem(name: "grant_type", value: "authorization_code")
                ],
                httpMethod: "POST")
        
        case .authentication:
            guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize")
            else {
                preconditionFailure("Unable to construct url")
            }
            
            urlComponents.queryItems = [
                URLQueryItem(
                    name: "client_id", value: accessKey),
                URLQueryItem(
                    name: "redirect_uri", value: redirectURI),
                URLQueryItem(
                    name: "response_type", value: "code"),
                URLQueryItem(
                    name: "scope", value: accessScope)
            ]
            
            guard let url = urlComponents.url else {
                preconditionFailure("Unable to construct Url")
            }
            let request = URLRequest(url: url)
            return request
        
        case .photos(let pageNumber):
            var request = URLRequest.makeHTTPRequest(
                path: "/photos",
                queryItems: [
                    URLQueryItem(
                        name: "client_id", value: accessKey),
                    URLQueryItem(
                        name: "page", value: "\(pageNumber)"),
                    URLQueryItem(
                        name: "per_page", value: "9"),
                    URLQueryItem(
                        name: "order_by", value: "popular")
                ]
            )
            return request
        }
    }
}
