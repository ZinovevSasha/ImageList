//
//  Oauth2TokenStorage.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.01.2023.
//

import Foundation
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private let keyChain = KeychainWrapper.standard
    
    private enum Key: String {
        case token
    }
    
    var token: String? {
        get {
            keyChain.string(forKey: Key.token.rawValue)
        }
        set {
            guard let newValue = newValue else { return }
            keyChain.set(newValue, forKey: Key.token.rawValue)
        }
    }
}
