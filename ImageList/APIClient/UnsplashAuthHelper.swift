//
//  AuthHelper.swift
//  ImageList
//
//  Created by Александр Зиновьев on 06.03.2023.
//

import Foundation

protocol UnsplashAuthHelperProtocol {
    func authRequest() -> URLRequest
    func code(from url: URL?) -> String?
}

protocol UnsplashAuthTokenRequestProtocol {
    func oAuthToken(code: String) -> URLRequest
}

final class UnsplashAuthHelper {
    let configuration: UnsplashAuthConfiguration
    
    init(_ configuration: UnsplashAuthConfiguration) {
        self.configuration = configuration
    }
    
    var components: [String] {
        let authString = configuration.authRequestHostAndPath
        return authString.components(separatedBy: "/")
    }
    
    var host: String {
        // Extract the host (first component)
        if let host = components.first {
            return host
        }
        preconditionFailure("No host")
    }
    
    var path: String {
        // Extract the path (all components except the first with a preceding "/" character)
        let path = "/" + components
            .dropFirst()
            .joined(separator: "/")
        return path
    }
}
    
extension UnsplashAuthHelper: UnsplashAuthHelperProtocol {
    func authRequest() -> URLRequest {
        return URLRequest.makeHTTPRequest(
            host: host,
            path: path,
            queryItems: [
                URLQueryItem(
                    name: "client_id", value: configuration.accessKey),
                URLQueryItem(
                    name: "redirect_uri", value: configuration.redirectURI),
                URLQueryItem(
                    name: "response_type", value: "code"),
                URLQueryItem(
                    name: "scope", value: configuration.accessScope)
            ]
        )
    }
    
    func code(from url: URL?) -> String? {
        if let url = url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == path + "/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        } else {
            return nil
        }
    }
}

extension UnsplashAuthHelper: UnsplashAuthTokenRequestProtocol {
    func oAuthToken(code: String) -> URLRequest {
        return URLRequest.makeHTTPRequest(
            host: host,
            path: "/oauth/token",
            queryItems: [
                URLQueryItem(name: "client_id", value: configuration.accessKey),
                URLQueryItem(name: "client_secret", value: configuration.secretKey),
                URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "grant_type", value: "authorization_code")
            ],
            httpMethod: .post)
    }
}
