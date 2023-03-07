extension UnsplashAuthConfiguration {
    static var standard: UnsplashAuthConfiguration {
        return UnsplashAuthConfiguration(
            accessKey: AccessKey,
            secretKey: SecretKey,
            redirectURI: RedirectURI,
            accessScope: AccessScope,
            defaultBaseHost: DefaultBaseHost,
            authorizeURLString: UnsplashAuthorizeURLString,
            tokenURLString: UnsplashTokenURLString
        )
    }
}

protocol UnsplashAuthConfigurationProtocol {
    var accessKey: String { get }
    var secretKey: String { get }
    var redirectURI: String { get }
    var accessScope: String { get }
    var defaultBaseHost: String { get }
    var authorizeURLString: String { get }
    var tokenURLString: String { get }
}

struct UnsplashAuthConfiguration: UnsplashAuthConfigurationProtocol {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseHost: String
    let authorizeURLString: String
    let tokenURLString: String
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: [Scope],
        defaultBaseHost: String,
        authorizeURLString: String,
        tokenURLString: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope.map { $0.string }.joined(separator: "+")
        self.defaultBaseHost = defaultBaseHost
        self.authorizeURLString = authorizeURLString
        self.tokenURLString = tokenURLString
    }
}

let AccessKey = "SS4lXp7vzIwOgPt0F2sOiUW-jsD6--h2Red2jA82kbQ"
let SecretKey = "0xgcQI41BRbflXzVQ8oIAmKQd--Dk-cYJ-TV44d5d3k"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope: [Scope] = [.public, .readUser, .writeLikes]
let DefaultBaseHost = "api.unsplash.com"
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
let UnsplashTokenURLString = "https://unsplash.com/oauth/token"
