//
//  URLRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 31.01.2023.
//

import Foundation

protocol RequestBuilding {
    func makeHTTPRequest(
        scheme: String,
        host: String,
        path: String,
        queryItems: [URLQueryItem]?,
        httpMethod: HTTPMethod
    ) -> URLRequest
}

struct RequestBuilder: RequestBuilding {
    func makeHTTPRequest(
        scheme: String,
        host: String,
        path: String,
        queryItems: [URLQueryItem]?,
        httpMethod: HTTPMethod
    ) -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
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
