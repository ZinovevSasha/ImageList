//
//  URLRequest.swift
//  ImageList
//
//  Created by Александр Зиновьев on 31.01.2023.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        scheme: String = "https",
        host: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        httpMethod: HTTPMethod = .get
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

protocol URLRequestBuilding {
    func build(path: String, method: String) -> URLRequest?
}

class URLRequestBuilder: URLRequestBuilding {
    let baseURL: URL
    let headers: [String: String]

    init(baseURL: URL, headers: [String: String]) {
        self.baseURL = baseURL
        self.headers = headers
    }

    func build(path: String, method: String) -> URLRequest? {
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        else {
            return nil
        }
        urlComponents.scheme = "https"
        guard let url = urlComponents.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }

        return request
    }
}
