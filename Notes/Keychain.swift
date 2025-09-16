//
//  Keychain.swift
//  Notes
//
//  Created by NxtWave on 18/08/25.
//

import Foundation
import Security

enum KeychainError: Error { case duplicate, notFound, unexpectedStatus(OSStatus) }

struct Keychain {
    static func savePasswordHash(_ data: Data, service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem { throw KeychainError.duplicate }
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    static func updatePasswordHash(_ data: Data, service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attrs: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attrs as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    static func readPasswordHash(service: String, account: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        var out: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &out)
        guard status != errSecItemNotFound else { throw KeychainError.notFound }
        guard status == errSecSuccess, let data = out as? Data else {
            throw KeychainError.unexpectedStatus(status)
        }
        return data
    }

    static func delete(service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

