//
//  JSBiometricOptions.swift
//  JSKeychain
//
//  Created by Jonathan Sack on 7/11/25.
//

public struct JSBiometricOptions {

    // Properties
    public let required: Bool
    public let fallbackToPasscode: Bool
    public let localizedReason: String
    
    // Init
    public init(required: Bool = false, fallbackToPasscode: Bool = true, localizedReason: String = "Authenticate to access secure data") {
        self.required = required
        self.fallbackToPasscode = fallbackToPasscode
        self.localizedReason = localizedReason
    }
}
