//
//  JSKeychainError.swift
//  JSKeychain
//
//  Created by Jonathan Sack on 3/14/24.
//

import Foundation

// MARK: - JSKeychain Error
public enum JSKeychainError: LocalizedError {
    case itemNotFound
    case duplicateItem
    case invalidData
    case unhandledError(status: OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Item not found in keychain"
        case .duplicateItem:
            return "Item already exists in keychain"
        case .invalidData:
            return "Invalid data format"
        case .unhandledError(let status):
            return "Keychain error: \(status)"
        }
    }
}
