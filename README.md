# JSKeychain

JSKeychain is a lightweight, secure framework for managing sensitive data in the iOS Keychain. It provides an easy-to-use interface for storing, retrieving, updating, and deleting credentials and other secure data.

## Features

- **Secure Storage**: Leverages the iOS Keychain for secure storage of sensitive data.
- **Simple API**: A straightforward, protocol-oriented API for managing keychain items.
- **Error Handling**: Comprehensive error handling to catch and respond to various keychain operation errors.
<br>

## Requirements

- iOS 10.0+
- Swift 5.0+
<br>

## Installation

### Swift Package Manager

You can install JSKeychain using the [Swift Package Manager](https://swift.org/package-manager/) by adding the following line to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/jaysack/JSKeychain.git", from: "1.0.0")
]
```


### Manual Installation

Drag and drop the `JSKeychain.swift` file into your Xcode project, making sure to select Copy items if needed.
<br>

## Usage

First, import JSKeychain in your Swift file:

```swift
import JSKeychain
```

### Creating a New Item

```swift
do {
    let data = "password".data(using: .utf8)!
    try JSKeychain.shared.create(data, service: "com.example.MyApp", account: "user@example.com")
} catch {
    print(error)
}
```

### Reading an Item

```swift
do {
    if let data = try JSKeychain.shared.read(service: "com.example.MyApp", account: "user@example.com"),
       let password = String(data: data, encoding: .utf8) {
        print(password)
    }
} catch {
    print(error)
}
```

### Updating an Item

```swift
do {
    let newData = "newPassword".data(using: .utf8)!
    try JSKeychain.shared.update(newData, service: "com.example.MyApp", account: "user@example.com")
} catch {
    print(error)
}
```

### Deleting an Item

```swift
do {
    try JSKeychain.shared.delete(service: "com.example.MyApp", account: "user@example.com")
} catch {
    print(error)
}
```
<br>

## Error Handling
JSKeychain throws `JSKeychainError` enumerations for various errors. Handle these in your application to gracefully deal with keychain operation failures.
<br>


## Contributing
Contributions are very welcome 🙌. Please submit a pull request or file an issue for anything you'd like to add or change.
<br>

## License
JSKeychain is released under the MIT license.
<br>