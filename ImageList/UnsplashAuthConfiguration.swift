extension UnsplashAuthConfiguration {
    static var standard: UnsplashAuthConfiguration {
        return UnsplashAuthConfiguration(
            accessKey: AccessKey,
            secretKey: SecretKey,
            redirectURI: RedirectURI,
            accessScope: AccessScope,
            defaultBaseHost: DefaultBaseHost,
            authRequestHostAndPath: AuthRequestHostAndPath,
            authTokenHostAndPath: AuthTokenHostAndPath
        )
    }
}

struct UnsplashAuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseHost: String
    let authRequestHostAndPath: String
    let authTokenHostAndPath: String
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        defaultBaseHost: String,
        authRequestHostAndPath: String,
        authTokenHostAndPath: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseHost = defaultBaseHost
        self.authRequestHostAndPath = authRequestHostAndPath
        self.authTokenHostAndPath = authTokenHostAndPath
    }
}

let AccessKey = "SS4lXp7vzIwOgPt0F2sOiUW-jsD6--h2Red2jA82kbQ"
let SecretKey = "0xgcQI41BRbflXzVQ8oIAmKQd--Dk-cYJ-TV44d5d3k"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseHost = "api.unsplash.com"
let AuthRequestHostAndPath = "unsplash.com/oauth/authorize"
let AuthTokenHostAndPath = "unsplash.com/oauth/token"
