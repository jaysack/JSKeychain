//
//  JSKeychainConfiguration.swift
//  JSKeychain
//
//  Created by Jonathan Sack on 1/16/25.
//

import Foundation

public struct JSKeychainConfiguration: Sendable {
    
    // MARK: Properties
    /// Optional access group for keychain sharing between apps
    public let accessGroup: String?
    
    /// Whether to sync keychain items to iCloud Keychain
    /// Default is false for security - must explicitly opt-in
    /// Note: Items with "ThisDeviceOnly" accessibility will never sync regardless of this setting
    public let syncToICloud: Bool
    
    /// JSON encoder for encoding Codable items
    public let encoder: JSONEncoder
    
    /// JSON decoder for decoding Codable items
    public let decoder: JSONDecoder
    
    // MARK: Init
    public init(
        accessGroup: String? = nil,
        syncToICloud: Bool = false,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.accessGroup = accessGroup
        self.syncToICloud = syncToICloud
        self.encoder = encoder
        self.decoder = decoder
    }
}