//
//  Oauth2TokenStorage.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.01.2023.
//

import Foundation

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            return userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.token.rawValue)
        }
    }
}
