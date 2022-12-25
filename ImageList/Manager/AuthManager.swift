final class AuthManager {
    static let shared = AuthManager()

    private init() {}
    
    var isSignedIn = false
    
    // TODO: - save isSignedIn into userDefaults
}
