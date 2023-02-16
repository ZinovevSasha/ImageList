//
//  Oauth2TokenStorage.swift
//  ImageList
//
//  Created by Александр Зиновьев on 28.01.2023.
//

import Foundation

protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
    func deleteToken()
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
            guard let newValue = newValue else { return }
            do {
                try save(
                    service: KeyPath.imageList.rawValue,
                    account: KeyPath.key.rawValue,
                    password: newValue.data(using: .utf8) ?? Data()
                )
            } catch {
                print("OAuth2TokenStorage", error)
            }
        }
    }
    
    // MARK: - PRIVATE
    func deleteToken() {
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


// MARK: - Example from Yandex Book not working
/*
final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private let appTag = "com.imagefeed.keys".data(using: .utf8)!

    public var token: String? {
        get {
            let query: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecAttrApplicationTag as String: appTag,
                kSecReturnData as String: true
            ]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)              // 2
            guard status == errSecSuccess else {                                        // 3
                // ошибка
                return nil
            }

            guard                                                                       // 4
                let existingItem = item as? [String: Any],
                let tokenData = existingItem[kSecValueData as String] as? Data,
                let tokenKey = String(data: tokenData, encoding: String.Encoding.utf8)
            else {
                // ошибка
                return nil
            }
            return  tokenKey
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            let token = newValue.data(using: .utf8)!
            let appTag = "com.imagefeed.keys".data(using: .utf8)!
            let addquery: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: appTag,
                kSecValueRef as String: token
            ]

            let status = SecItemAdd(addquery as CFDictionary, nil)
            guard status == errSecSuccess else {
                return
            }
        }
    }

    func deleteToken() { }
}
*/
