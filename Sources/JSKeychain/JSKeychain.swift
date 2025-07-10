//
//  JSKeychain.swift
//  JSKeychain
//
//  Created by Jonathan Sack on 3/14/24.
//

import Foundation

final public class JSKeychain: JSKeychainProtocol {

    // MARK: Init
    private init() { }

    // MARK: Properties
    public static let shared = JSKeychain()
    public var allowOverrides: Bool = false

    // MARK: Create
    public func create(_ data: Data, service: String, account: String, class: CFString = kSecClassGenericPassword) throws {
        try create(data, service: service, account: account, class: `class`, accessGroup: nil)
    }
    
    public func create(_ data: Data, service: String, account: String, class: CFString = kSecClassGenericPassword, accessGroup: String?) throws {
        // Make query
        var query: [CFString: Any] = [
            kSecValueData: data,
            kSecClass: `class`,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        // Add access group if provided
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        // Check save status
        let saveStatus = SecItemAdd(query as CFDictionary, nil)
        // Check for existing item (if allowed)
        if saveStatus == errSecDuplicateItem && allowOverrides {
            try update(data, service: service, account: account, class: `class`, accessGroup: accessGroup)
        // Check errors
        } else if saveStatus != errSecSuccess {
            throw JSKeychainError.unableToCreateItem(saveStatus)
        }
    }
    
    // MARK: Read
    public func read(service: String, account: String, class: CFString = kSecClassGenericPassword) throws -> Data? {
        try read(service: service, account: account, class: `class`, accessGroup: nil)
    }
    
    public func read(service: String, account: String, class: CFString = kSecClassGenericPassword, accessGroup: String?) throws -> Data? {
        // Make query
        var query: [CFString: Any] = [
            kSecClass: `class`,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
        ]
        // Add access group if provided
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        // Set result
        var result: AnyObject?
        let readStatus = SecItemCopyMatching(query as CFDictionary, &result)
        // Check errors
        if readStatus != errSecSuccess {
            throw JSKeychainError.unableToReadItem(readStatus)
        }
        // Downcast to Data type
        guard let data = result as? Data else { throw JSKeychainError.invalidDataType }
        return data
    }

    // MARK: Update
    public func update(_ data: Data, service: String, account: String, class: CFString = kSecClassGenericPassword) throws {
        try update(data, service: service, account: account, class: `class`, accessGroup: nil)
    }
    
    public func update(_ data: Data, service: String, account: String, class: CFString = kSecClassGenericPassword, accessGroup: String?) throws {
        // Make query
        var query: [CFString: Any] = [
            kSecClass: `class`,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        // Add access group if provided
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        // Update item
        let updatedData = [kSecValueData: data] as CFDictionary
        let updateStatus = SecItemUpdate(query as CFDictionary, updatedData)
        // Check errors
        if updateStatus != errSecSuccess {
            throw JSKeychainError.unableToUpdateItem(updateStatus)
        }
    }

    // MARK: Delete
    public func delete(service: String, account: String, class: CFString = kSecClassGenericPassword) throws {
        try delete(service: service, account: account, class: `class`, accessGroup: nil)
    }
    
    public func delete(service: String, account: String, class: CFString = kSecClassGenericPassword, accessGroup: String?) throws {
        // Make query
        var query: [CFString: Any] = [
            kSecClass: `class`,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        // Add access group if provided
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        // Delete item
        let deleteStatus = SecItemDelete(query as CFDictionary)
        // Check errors
        if deleteStatus != errSecSuccess {
            throw JSKeychainError.unableToDeleteItem(deleteStatus)
        }
    }
}
