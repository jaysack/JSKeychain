# Changelog

All notable changes to JSKeychain will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.1] - 2025-10-03

### Fixed

- **Critical iCloud Sync Bug**: Fixed `save()` method to properly update the sync attribute when re-saving existing keychain items
  - Previously, items saved with `syncToICloud: false` could not be updated to `syncToICloud: true` (and vice versa)
  - The update query now uses `kSecAttrSynchronizableAny` to find items regardless of their current sync state
  - The update attributes now include `kSecAttrSynchronizable` to properly change the sync state
  - Added access group to update query for proper matching across app groups
  - **Impact**: This fixes scenarios where toggling iCloud sync in settings would fail silently, preventing accounts from syncing across devices

### Technical Details

The bug was caused by:
1. Using `kSecAttrSynchronizable = true` in the update query, which only matched items already synced
2. Not including `kSecAttrSynchronizable` in the update attributes dictionary
3. Missing access group in the update query

This prevented the keychain migration flow from working when users:
- Enabled iCloud sync for previously saved items
- Disabled iCloud sync for currently synced items
- Switched between different sync configurations

## [2.3.0] - 2025-09-XX

### Added
- Initial version with iCloud Keychain sync support
- Type-safe Codable storage
- Async/await support
- Biometric authentication
- Keychain sharing via App Groups
- Comprehensive access control options
