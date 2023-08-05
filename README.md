# 🗝️ KeychainBridge

Provides an easier way to manipulate keys in MacOS keychain

```swift
let bridge = KeychainBridge(serviceName: "com.aydarmedia.keychainbridge")
let account = "bridge"
let tokenContent = "test_token"
let tokenContentOverwritten = "bruh"

try bridge.saveToken(tokenContent, account: account)

XCTAssertEqual(try bridge.getToken(account: account), tokenContent)

try bridge.saveToken(tokenContentOverwritten, account: account)

XCTAssertEqual(try bridge.getToken(account: account), tokenContentOverwritten)

try bridge.deleteToken(account: account)

XCTAssertThrowsError(try bridge.getToken(account: account))
```
