//
//  JSKeychainItem.swift
//  JSKeychain
//
//  Created by Jonathan Sack on 7/11/25.
//

import Foundation

public struct JSKeychainItem {

    // Properties
    public let service: String
    public let account: String
    public let createdAt: Date?
    public let modifiedAt: Date?
    
    // Init
    public init(service: String, account: String, createdAt: Date? = nil, modifiedAt: Date? = nil) {
        self.service = service
        self.account = account
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
