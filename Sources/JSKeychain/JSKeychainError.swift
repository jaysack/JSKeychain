//
//  JSKeychainError.swift
//  JSKeychain
//
//  Created by Jonathan Sack on 3/14/24.
//

import Foundation

public enum KSKeychainError: Error {
    case unableToCreateItem(OSStatus)
    case unableToReadItem(OSStatus)
    case unableToUpdateItem(OSStatus)
    case unableToDeleteItem(OSStatus)
    case invalidDataType
}
