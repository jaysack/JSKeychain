//
//  JSKeychainAccessibility.swift
//  JSKeychain
//
//  Created by Jonathan Sack on 7/11/25.
//

import Foundation

public enum JSKeychainAccessibility {
    /// Item is accessible only while the device is unlocked by the user.
    /// This is the most secure option for data that needs frequent access.
    /// Items become inaccessible when device locks and during restarts.
    /// Recommended for: Session tokens, temporary data
    case whenUnlocked
    
    /// Item is accessible after the device has been unlocked at least once after a restart.
    /// Data remains accessible even when device is locked, until next restart.
    /// Recommended for: Background refresh tokens, data needed by background tasks
    case afterFirstUnlock
    
    /// Item is only accessible when device has a passcode set.
    /// If user removes passcode, data becomes permanently inaccessible.
    /// This option never synchronizes to iCloud Keychain.
    /// Recommended for: Highly sensitive data that should be protected by device security
    case whenPasscodeSet
    
    /// Same as whenUnlocked but never synchronizes to iCloud Keychain.
    /// Item stays on this device only.
    /// Recommended for: Device-specific tokens, local-only credentials
    case whenUnlockedThisDeviceOnly
    
    /// Same as afterFirstUnlock but never synchronizes to iCloud Keychain.
    /// Item stays on this device only.
    /// Recommended for: Device-specific background tokens
    case afterFirstUnlockThisDeviceOnly
    
    /// Same as whenPasscodeSet (already device-only).
    /// Most restrictive option - requires passcode and never syncs.
    /// Recommended for: Highly sensitive device-specific data
    case whenPasscodeSetThisDeviceOnly
    
    public var cfString: CFString {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .whenPasscodeSet:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
