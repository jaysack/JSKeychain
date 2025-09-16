# JSKeychain

A modern Swift wrapper for iOS Keychain Services with async/await support, type-safe storage, and comprehensive access control options.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Guide](#usage-guide)
  - [Basic Operations](#basic-operations)
  - [Async/Await Support](#asyncawait-support)
  - [Access Control Options](#access-control-options)
  - [Biometric Authentication](#biometric-authentication)
  - [iCloud Keychain Sync](#icloud-keychain-sync)
  - [Keychain Sharing](#keychain-sharing)
  - [Custom Encoders/Decoders](#custom-encodersdecoders)
- [Security Best Practices](#security-best-practices)
- [API Reference](#api-reference)
- [License](#license)

## Features

- 🔐 **Type-safe**: Store any `Codable` type with compile-time safety
- ⚡ **Modern Swift**: Full async/await support for all operations
- 🔒 **Biometric Protection**: Touch ID/Face ID authentication support
- 📱 **Access Control**: Comprehensive security options for different use cases
- ☁️ **iCloud Keychain Sync**: Optional synchronization across devices
- 🔄 **Keychain Sharing**: Share data between your apps via App Groups
- 🎯 **Simple API**: Clean, intuitive methods - `save`, `read`, `delete`, `exists`, `listAll`
- 📦 **Zero Dependencies**: Pure Swift implementation
- 🍎 **Platform Support**: iOS 15+, macOS 13+, tvOS 15+, watchOS 8+

## Requirements

- iOS 15.0+ / macOS 13.0+ / tvOS 15.0+ / watchOS 8.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

### Swift Package Manager

Add JSKeychain to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/jaysack/JSKeychain.git", from: "2.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/jaysack/JSKeychain.git`
3. Select "Up to Next Major Version" with "2.0.0"

## Quick Start

```swift
import JSKeychain

// Initialize (local-only by default)
let keychain = JSKeychain()

// Initialize with iCloud sync enabled
let config = JSKeychainConfiguration(syncToICloud: true)
let cloudKeychain = JSKeychain(configuration: config)

// Save data
try await keychain.save("secret-token", service: "MyApp", account: "userToken")

// Read data
let token: String = try await keychain.read(service: "MyApp", account: "userToken")

// Check existence
if await keychain.exists(service: "MyApp", account: "userToken") {
    print("Token exists!")
}

// Delete data
try await keychain.delete(service: "MyApp", account: "userToken")
```

## Usage Guide

### Basic Operations

JSKeychain provides five core methods for keychain operations:

```swift
// Save any Codable type
struct Credentials: Codable {
    let username: String
    let password: String
}

let credentials = Credentials(username: "john", password: "secret123")
try keychain.save(credentials, service: "MyApp", account: "mainUser")

// Read with type inference
let stored: Credentials = try keychain.read(service: "MyApp", account: "mainUser")

// Check if item exists
if keychain.exists(service: "MyApp", account: "mainUser") {
    // Item exists
}

// List all items
let items = try keychain.listAll(service: "MyApp")
for item in items {
    print("Account: \(item.account), Created: \(item.createdAt)")
}

// Delete item
try keychain.delete(service: "MyApp", account: "mainUser")

// Delete all items for a service
try keychain.deleteAll(service: "MyApp")
```

### Async/Await Support

All methods support both synchronous and asynchronous operations:

```swift
// Synchronous
do {
    let token: String = try keychain.read(service: "MyApp", account: "token")
} catch {
    print("Error: \(error)")
}

// Asynchronous
Task {
    do {
        let token: String = try await keychain.read(service: "MyApp", account: "token")
    } catch {
        print("Error: \(error)")
    }
}

// Perfect for SwiftUI
struct LoginView: View {
    @State private var isLoggedIn = false
    let keychain = JSKeychain()
    
    var body: some View {
        Text(isLoggedIn ? "Welcome!" : "Please login")
            .task {
                isLoggedIn = await keychain.exists(service: "MyApp", account: "authToken")
            }
    }
}
```

### Access Control Options

JSKeychain provides comprehensive access control options to secure your data:

```swift
// Most secure - only accessible when device is unlocked
try await keychain.save(
    sensitiveData,
    service: "MyApp",
    account: "secure",
    accessibility: .whenUnlocked  // Default
)

// Available after first unlock (good for background tasks)
try await keychain.save(
    refreshToken,
    service: "MyApp", 
    account: "refreshToken",
    accessibility: .afterFirstUnlock
)

// Requires device passcode
try await keychain.save(
    verySecretData,
    service: "MyApp",
    account: "topsecret",
    accessibility: .whenPasscodeSet
)

// Device-only (won't sync to iCloud Keychain)
try await keychain.save(
    deviceToken,
    service: "MyApp",
    account: "deviceOnly",
    accessibility: .whenUnlockedThisDeviceOnly
)
```

#### Access Control Options Explained

| Option | When Accessible | Can Sync to iCloud* | Use Case |
|--------|----------------|-------------------|----------|
| `.whenUnlocked` | Device unlocked | ✅ Yes | Session tokens, user data |
| `.afterFirstUnlock` | After first unlock since boot | ✅ Yes | Background refresh tokens |
| `.whenPasscodeSet` | Device has passcode | ❌ No | Highly sensitive data |
| `.whenUnlockedThisDeviceOnly` | Device unlocked | ❌ No | Device-specific tokens |
| `.afterFirstUnlockThisDeviceOnly` | After first unlock | ❌ No | Device-specific background data |
| `.whenPasscodeSetThisDeviceOnly` | Device has passcode | ❌ No | Maximum security + device only |

*iCloud sync only occurs when `syncToICloud: true` is set in configuration AND using a non-device-only accessibility option.

### Biometric Authentication

Protect sensitive data with Face ID or Touch ID:

```swift
// Save with biometric protection
let biometricOptions = JSBiometricOptions(
    required: true,
    fallbackToPasscode: true,
    localizedReason: "Authenticate to save your password"
)

try await keychain.save(
    password,
    service: "MyApp",
    account: "userPassword",
    accessibility: .whenUnlocked,
    biometricOptions: biometricOptions
)

// Read with biometric authentication
let password: String = try await keychain.read(
    service: "MyApp",
    account: "userPassword",
    biometricReason: "Authenticate to access your password"
)
```

### iCloud Keychain Sync

Synchronize keychain items across user's devices via iCloud:

```swift
// Initialize with iCloud sync enabled
let config = JSKeychainConfiguration(
    syncToICloud: true  // Default is false for security
)
let keychain = JSKeychain(configuration: config)

// Save items that will sync to iCloud
try await keychain.save(
    userPreferences,
    service: "MyApp",
    account: "preferences",
    accessibility: .whenUnlocked  // Must use non-device-only accessibility
)

// Items with "ThisDeviceOnly" accessibility never sync
try await keychain.save(
    deviceSpecificToken,
    service: "MyApp", 
    account: "deviceToken",
    accessibility: .whenUnlockedThisDeviceOnly  // Won't sync even with syncToICloud: true
)

// Read will automatically find both local and synced items
let prefs: UserPreferences = try await keychain.read(
    service: "MyApp",
    account: "preferences"
)
```

**Important Notes:**
- iCloud sync is disabled by default for security - explicitly opt-in with `syncToICloud: true`
- Items only sync when using non-device-only accessibility options
- Synced items are available on all devices signed into the same iCloud account
- Items saved without sync cannot be "upgraded" - you must delete and re-save to enable sync

### Keychain Sharing

Share keychain items between your apps using App Groups:

```swift
// 1. Enable "Keychain Sharing" capability in Xcode for all apps
// 2. Add the same Keychain Group to all apps

// App 1: Save shared data
let sharedKeychain = JSKeychain(accessGroup: "group.com.company.apps")
try await sharedKeychain.save(
    sharedSecret,
    service: "SharedService",
    account: "sharedData"
)

// App 2: Read shared data
let sharedKeychain = JSKeychain(accessGroup: "group.com.company.apps")
let secret: String = try await sharedKeychain.read(
    service: "SharedService",
    account: "sharedData"
)
```

### Custom Encoders/Decoders

Use custom JSON encoders/decoders for special requirements:

```swift
// Custom date formatting
let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601

// Using the configuration approach
let config = JSKeychainConfiguration(
    syncToICloud: false,
    encoder: encoder,
    decoder: decoder
)
let keychain = JSKeychain(configuration: config)

// Or using the convenience initializer (no iCloud sync)
let keychain = JSKeychain(encoder: encoder, decoder: decoder)

// Now dates will be encoded/decoded using ISO8601 format
struct Event: Codable {
    let name: String
    let date: Date
}

let event = Event(name: "Launch", date: Date())
try await keychain.save(event, service: "MyApp", account: "event")
```

## Security Best Practices

### 1. Choose the Right Access Control

- Use `.whenUnlocked` (default) for most data
- Use `.afterFirstUnlock` only for data needed by background tasks
- Use `.whenPasscodeSet` for highly sensitive data
- Add `ThisDeviceOnly` suffix to prevent iCloud Keychain sync

### 2. Use Biometric Protection for Sensitive Data

```swift
// Protect financial or health data
let biometricOptions = JSBiometricOptions(
    required: true,
    fallbackToPasscode: false  // No fallback for maximum security
)
```

### 3. Implement Proper Error Handling

```swift
do {
    let token: String = try await keychain.read(service: "MyApp", account: "token")
} catch JSKeychainError.itemNotFound {
    // Handle missing item
} catch JSKeychainError.invalidData {
    // Handle corrupted data
} catch {
    // Handle other errors
}
```

### 4. Clear Sensitive Data on Logout

```swift
func logout() async throws {
    // Clear all user data
    try await keychain.deleteAll(service: "MyApp")
}
```

### 5. Use Unique Service/Account Combinations

```swift
// Good: Unique identifiers
try await keychain.save(token, service: "com.company.MyApp", account: "user-\(userID)-authToken")

// Avoid: Generic identifiers
try await keychain.save(token, service: "MyApp", account: "token")
```

### 6. Regular Security Audits

- Periodically review what data is stored in keychain
- Remove unused items
- Update access control levels as needed

## API Reference

### JSKeychain

```swift
class JSKeychain {
    // Initialize with configuration
    init(configuration: JSKeychainConfiguration = JSKeychainConfiguration())
    
    // Initialize with individual parameters (backward compatibility, no iCloud sync)
    init(accessGroup: String? = nil, encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder())
    
    // Save item
    func save<T: Codable>(_ item: T, service: String, account: String, accessibility: JSKeychainAccessibility = .whenUnlocked, biometricOptions: JSBiometricOptions? = nil) throws
    func save<T: Codable>(_ item: T, service: String, account: String, accessibility: JSKeychainAccessibility = .whenUnlocked, biometricOptions: JSBiometricOptions? = nil) async throws
    
    // Read item
    func read<T: Codable>(service: String, account: String, biometricReason: String? = nil) throws -> T
    func read<T: Codable>(service: String, account: String, biometricReason: String? = nil) async throws -> T
    
    // Delete item
    func delete(service: String, account: String) throws
    func delete(service: String, account: String) async throws
    
    // Check existence
    func exists(service: String, account: String) -> Bool
    func exists(service: String, account: String) async -> Bool
    
    // List items
    func listAll(service: String? = nil) throws -> [JSKeychainItem]
    func listAll(service: String? = nil) async throws -> [JSKeychainItem]
    
    // Delete all items
    func deleteAll(service: String? = nil) throws
    func deleteAll(service: String? = nil) async throws
}
```

### JSKeychainError

```swift
enum JSKeychainError: LocalizedError {
    case itemNotFound           // Item doesn't exist
    case duplicateItem         // Item already exists (not used in current implementation)
    case invalidData           // Data corruption or decoding failure
    case unhandledError(status: OSStatus)  // Other keychain errors
}
```

### JSKeychainConfiguration

```swift
struct JSKeychainConfiguration {
    let accessGroup: String?      // Optional app group for keychain sharing
    let syncToICloud: Bool        // Enable iCloud Keychain sync (default: false)
    let encoder: JSONEncoder      // JSON encoder for Codable types
    let decoder: JSONDecoder      // JSON decoder for Codable types
    
    init(
        accessGroup: String? = nil,
        syncToICloud: Bool = false,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    )
}
```

### JSKeychainItem

```swift
struct JSKeychainItem {
    let service: String
    let account: String
    let createdAt: Date?
    let modifiedAt: Date?
}
```

## License

JSKeychain is available under the MIT license. See the LICENSE file for more info.
