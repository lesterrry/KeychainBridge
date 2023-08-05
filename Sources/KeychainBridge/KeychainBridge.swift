//
//  KeychainBridge.swift
//  KeychainBridge
//
//  Created by aydar.media on 06.08.2023.
//

import Foundation
import Security

struct SecurityError: Error {
    var message: String?
}

public struct Keychain {
    private let serviceName: String
    
    public init(serviceName: String) {
        self.serviceName = serviceName
    }
    
    public func saveToken(_ token: String, account: String) throws {
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: self.serviceName
        ]
        
        // First, try to fetch an existing item
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {  // Existing item found, update it
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            try itemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        } else if status == errSecItemNotFound {  // Item not found, add a new one
            var newQuery = query
            newQuery[kSecValueData as String] = data
            try itemAdd(newQuery as CFDictionary)
        } else {
            throw SecurityError(message: "Failed with \(status) code")
        }
    }
    
    public func getToken(account: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: self.serviceName,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            if let data = dataTypeRef as? Data, let token = String(data: data, encoding: .utf8) {
                return token
            } else {
                throw SecurityError(message: "Failed to read decode Keychain data")
            }
        } else {
            throw SecurityError(message: "Failed to read from Keychain")
        }
    }
    
    public func deleteToken(account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: self.serviceName
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != noErr {
            throw SecurityError(message: "Failed to remove from Keychain")
        }
    }
    
    
    private func itemUpdate(_ query: CFDictionary, _ attributes: CFDictionary) throws {
        let status = SecItemUpdate(query, attributes)
        if status != noErr { throw SecurityError(message: "itemUpdate failed with \(status) code") }
    }
    
    private func itemAdd(_ query: CFDictionary) throws {
        let status = SecItemAdd(query, nil)
        if status != noErr { throw SecurityError(message: "itemAdd failed with \(status) code") }
    }
    
}
