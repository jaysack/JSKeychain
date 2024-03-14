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
    public func create(_ data: Data, service: String, account: String) throws {
        // Make query
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        // Check save status
        let saveStatus = SecItemAdd(query, nil)
        // Check for existing item (if allowed)
        if saveStatus == errSecDuplicateItem && allowOverrides {
            try update(data, service: service, account: account)
        // Check errors
        } else if saveStatus != errSecSuccess {
            throw JSKeychainError.unableToCreateItem(saveStatus)
        }
    }
    
    // MARK: Read
    public func read(service: String, account: String) throws -> Data? {
        // Make query
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
        ] as CFDictionary
        // Set result
        var result: AnyObject?
        let readStatus = SecItemCopyMatching(query, &result)
        // Check errors
        if readStatus != errSecSuccess {
            throw JSKeychainError.unableToReadItem(readStatus)
        }
        // Downcast to Data type
        guard let data = result as? Data else { throw JSKeychainError.invalidDataType }
        return data
    }

    // MARK: Update
    public func update(_ data: Data, service: String, account: String) throws {
        // Make query
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        // Update item
        let updatedData = [kSecValueData: data] as CFDictionary
        let updateStatus = SecItemUpdate(query, updatedData)
        // Check errors
        if updateStatus != errSecSuccess {
            throw JSKeychainError.unableToUpdateItem(updateStatus)
        }
    }

    // MARK: Delete
    public func delete(service: String, account: String) throws {
        // Make query
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        // Delete item
        let deleteStatus = SecItemDelete(query)
        // Check errors
        if deleteStatus != errSecSuccess {
            throw JSKeychainError.unableToDeleteItem(deleteStatus)
        }
    }
}
