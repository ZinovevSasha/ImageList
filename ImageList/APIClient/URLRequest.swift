//
//  URLRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 31.01.2023.
//

import Foundation

private enum URLRequestError: Error {
    case failedToCreateRequest
}

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        httpMethod: String,
        baseUrlString: String = "https://unsplash.com"
    ) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseUrlString) else {
            return nil
        }
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}
