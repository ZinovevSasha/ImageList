import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL?) -> String?
}

protocol AuthTokenRequestProtocol {
    func oAuthTokenRequest(code: String) -> URLRequest?
}

struct AuthHelper {
    // MARK: - Dependency
    private let configuration: AuthConfigurationProtocol
    
    // MARK: - Init (Dependency injection)
    init(_ configuration: AuthConfigurationProtocol) {
        self.configuration = configuration
    }
    
    private func getHostAndPath(from urlString: String) -> (host: String, path: String)? {
        let parts = urlString.components(separatedBy: "//")
        guard parts.count > 1 else {
            return nil
        }

        let host = parts[1]
            .components(separatedBy: "/")[0]
        let path = "/" + parts[1]
            .components(separatedBy: "/")
            .dropFirst()
            .joined(separator: "/")
        
        return (host, path)
    }
}

extension AuthHelper: AuthHelperProtocol {
    func authRequest() -> URLRequest? {
        let urlString = configuration.authorizeURLString
        guard
            let url = getHostAndPath(from: urlString)
        else {
            return nil
        }
        
        return URLRequest.makeHTTPRequest(
            host: url.host,
            path: url.path,
            queryItems: [
                URLQueryItem(name: "client_id", value: configuration.accessKey),
                URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
                URLQueryItem(name: "response_type", value: "code"),
                URLQueryItem(name: "scope", value: configuration.accessScope)
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

extension AuthHelper: AuthTokenRequestProtocol {
    func oAuthTokenRequest(code: String) -> URLRequest? {
        let urlString = configuration.tokenURLString
        guard
            let url = getHostAndPath(from: urlString)
        else {
            return nil
        }
        let request = URLRequest.makeHTTPRequest(
            host: url.host,
            path: url.path,
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
