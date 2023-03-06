//
//  URLRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 31.01.2023.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        host: String = baseURL,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        httpMethod: HTTPMethod = .get
    ) -> URLRequest {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure("Unable to create url")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.timeoutInterval = 30
        return request
    }
}
