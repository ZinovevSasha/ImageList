import Foundation

protocol UnsplashAuthHelperProtocol {
    func authRequest() -> URLRequest
    func code(from url: URL?) -> String?
}

protocol UnsplashAuthTokenRequestProtocol {
    func oAuthToken(code: String) -> URLRequest
}

struct UnsplashAuthHelper {
    // MARK: - Dependency
    private let configuration: UnsplashAuthConfiguration
    
    // MARK: - Init (Dependency injection)
    init(_ configuration: UnsplashAuthConfiguration) {
        self.configuration = configuration
    }
    
    private func getHostAndPath(from urlString: String) -> (host: String, path: String) {
        let parts = urlString.components(separatedBy: "//")
        let host = parts.count > 1 ? parts[1]
            .components(separatedBy: "/")[0] : ""
        let path = parts.count > 1 ? "/" + parts[1]
            .components(separatedBy: "/")
            .dropFirst()
            .joined(separator: "/") : ""
        return (host, path)
    }
}

extension UnsplashAuthHelper: UnsplashAuthHelperProtocol {
    func authRequest() -> URLRequest {
        let (host, path) = getHostAndPath(from: configuration.authorizeURLString)
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
            urlComponents.path == "/oauth/authorize/native",
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
        let (host, path) = getHostAndPath(from: configuration.tokenURLString)
        let request = URLRequest.makeHTTPRequest(
            host: host,
            path: path,
            queryItems: [
                URLQueryItem(name: "client_id", value: configuration.accessKey),
                URLQueryItem(name: "client_secret", value: configuration.secretKey),
                URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "grant_type", value: "authorization_code")
            ],
            httpMethod: .post)
        return request
    }
}
