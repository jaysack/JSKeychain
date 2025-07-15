//
//  JSKeychain.swift
//  JSKeychain
//
//  Created by Jonathan Sack on 3/14/24.
//

import Foundation
import LocalAuthentication

public final class JSKeychain: Sendable {
    
    // MARK: Properties
    // Optional access group for keychain sharing between apps
    private let accessGroup: String?
    // Encoder
    private let encoder: JSONEncoder
    // Decoder
    private let decoder: JSONDecoder
    
    // MARK: Init
    public init(accessGroup: String? = nil, encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        self.accessGroup = accessGroup
        self.encoder = encoder
        self.decoder = decoder
    }
    
    // MARK: - Save (Sync)
    public func save<T: Codable>(
        _ item: T,
        service: String,
        account: String,
        accessibility: JSKeychainAccessibility = .whenUnlocked,
        biometricOptions: JSBiometricOptions? = nil
    ) throws {
        
        // Encode the item
        let data = try encoder.encode(item)
        
        // Build query
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.lowercased(),
            kSecAttrAccount as String: account.lowercased(),
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility.cfString
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Add biometric protection if requested
        if let biometric = biometricOptions, biometric.required {
            let access = SecAccessControlCreateWithFlags(
                nil,
                accessibility.cfString,
                biometric.fallbackToPasscode ? .userPresence : .biometryCurrentSet,
                nil
            )
            query[kSecAttrAccessControl as String] = access
        }
        
        // Try to update first
        let updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.lowercased(),
            kSecAttrAccount as String: account.lowercased()
        ]
        
        let updateAttributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility.cfString
        ]
        
        var status = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
        
        // If item doesn't exist, add it
        if status == errSecItemNotFound {
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        guard status == errSecSuccess else {
            throw JSKeychainError.unhandledError(status: status)
        }
    }
    
    // MARK: - Save (Async)
    public func save<T: Codable>(
        _ item: T,
        service: String,
        account: String,
        accessibility: JSKeychainAccessibility = .whenUnlocked,
        biometricOptions: JSBiometricOptions? = nil
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    try self.save(
                        item,
                        service: service,
                        account: account,
                        accessibility: accessibility,
                        biometricOptions: biometricOptions
                    )
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Read (Sync)
    public func read<T: Codable>(
        service: String,
        account: String,
        biometricReason: String? = nil
    ) throws -> T {
        
        // Build query
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.lowercased(),
            kSecAttrAccount as String: account.lowercased(),
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Add biometric authentication context if needed
        if let reason = biometricReason {
            let context = LAContext()
            context.localizedReason = reason
            query[kSecUseAuthenticationContext as String] = context
        }
        
        // Execute query
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw JSKeychainError.itemNotFound
            }
            throw JSKeychainError.unhandledError(status: status)
        }
        
        guard let data = result as? Data else {
            throw JSKeychainError.invalidData
        }
        
        // Decode the data
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw JSKeychainError.invalidData
        }
    }
    
    // MARK: - Read (Async)
    public func read<T: Codable>(
        service: String,
        account: String,
        biometricReason: String? = nil
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let result: T = try self.read(
                        service: service,
                        account: account,
                        biometricReason: biometricReason
                    )
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Delete (Sync)
    public func delete(service: String, account: String) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.lowercased(),
            kSecAttrAccount as String: account.lowercased()
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw JSKeychainError.unhandledError(status: status)
        }
    }
    
    // MARK: - Delete (Async)
    public func delete(service: String, account: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    try self.delete(service: service, account: account)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Exists (Sync)
    public func exists(service: String, account: String) -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.lowercased(),
            kSecAttrAccount as String: account.lowercased(),
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Exists (Async)
    public func exists(service: String, account: String) async -> Bool {
        await withCheckedContinuation { continuation in
            Task {
                let result = self.exists(service: service, account: account)
                continuation.resume(returning: result)
            }
        }
    }
    
    // MARK: - List All (Sync)
    public func listAll(service: String? = nil) throws -> [JSKeychainItem] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        // Add service filter if specified
        if let service = service?.lowercased() {
            query[kSecAttrService as String] = service
        }
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return []
            }
            throw JSKeychainError.unhandledError(status: status)
        }
        
        guard let items = result as? [[String: Any]] else {
            return []
        }
        
        return items.compactMap { attributes in
            guard let service = attributes[kSecAttrService as String] as? String,
                  let account = attributes[kSecAttrAccount as String] as? String
            else {
                return nil
            }
            
            let createdAt = attributes[kSecAttrCreationDate as String] as? Date
            let modifiedAt = attributes[kSecAttrModificationDate as String] as? Date
            
            return JSKeychainItem(
                service: service,
                account: account,
                createdAt: createdAt,
                modifiedAt: modifiedAt
            )
        }
    }
    
    // MARK: - List All (Async)
    public func listAll(service: String? = nil) async throws -> [JSKeychainItem] {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let result = try self.listAll(service: service)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Delete All (Sync)
    public func deleteAll(service: String? = nil) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        // Add service filter if specified
        if let service = service?.lowercased() {
            query[kSecAttrService as String] = service
        }
        
        // Add access group if specified
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw JSKeychainError.unhandledError(status: status)
        }
    }
}
