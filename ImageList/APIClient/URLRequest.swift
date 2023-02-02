//
//  URLRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 31.01.2023.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        httpMethod: String,
        baseUrlString: String = "https://unsplash.com"
    ) -> URLRequest {
        var urlComponents = URLComponents(string: baseUrlString)!
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = httpMethod
        return request
    }
}
