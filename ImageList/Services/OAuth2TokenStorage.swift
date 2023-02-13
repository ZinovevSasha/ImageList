//
//  Oauth2TokenStorage.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.01.2023.
//

import Foundation

protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
    // You will show the only info I tell you!
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private let userDefaults = UserDefaults.standard
    // Conform to you, ohh my Lord Protocol
    
    // Public
    var token: String? {
        get {
            // UserDefaults Give me data!
            return userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            // UserDefaults Save data!
            userDefaults.setValue(newValue, forKey: Keys.token.rawValue)
        }
    }
    
    private enum Keys: String {
        case token
    }
    
    deinit {
        print("deinit... \(String(describing: self))")
    }
}
