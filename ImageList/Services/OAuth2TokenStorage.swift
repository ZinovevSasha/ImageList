//
//  Oauth2TokenStorage.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.01.2023.
//

import Foundation

protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol{
    // MARK: - PUBLIC
    public var token: String? {
        get {
            guard let data = get(
                service: KeyPath.imageList.rawValue,
                account: KeyPath.key.rawValue)
            else {
                print("OAuth2TokenStorage failed to read password")
                return nil
            }
            return String(decoding: data, as: UTF8.self)
        }
        set(newValue) {
            deleteToken()
            do {
                try save(
                    service: KeyPath.imageList.rawValue,
                    account: KeyPath.key.rawValue,
                    password: newValue?.data(using: .utf8) ?? Data()
                )
            } catch {
                print("OAuth2TokenStorage", error)
            }
        }
    }
    
    // MARK: - PRIVATE
    private func deleteToken() {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeyPath.imageList.rawValue as AnyObject,
            kSecAttrAccount as String: KeyPath.key.rawValue as AnyObject
        ] as CFDictionary
        SecItemDelete(query)
    }
    
    private func get(service: String, account: String) -> Data? {
        // class, service, account, data, limit
        let addQuery: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(addQuery as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            print("OAuth2TokenStorage Error \(status)")
            return nil
        }
        return result as? Data
    }
    
    private func save(service: String, account: String, password: Data) throws {
        // class, service, account, data
        let addQuery: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeyChainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeyChainError.unknownError(status)
        }
    }
    
    private enum KeyPath: String {
        case imageList
        case key
    }
    
    private enum KeyChainError: Error {
        case duplicateEntry
        case unknownError(OSStatus)
    }
}
