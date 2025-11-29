<picture>
  <source srcset="https://github.com/user-attachments/assets/88f04eb0-c438-4d0e-831b-dd97d90132e4" media="(prefers-color-scheme: light)"/>
  <source srcset="https://github.com/user-attachments/assets/78d5a94f-9b27-4994-8136-817187091bc3"  media="(prefers-color-scheme: dark)"/>
  <img src="https://github.com/user-attachments/assets/88f04eb0-c438-4d0e-831b-dd97d90132e4" alt="SwiftSMTP"/>
</picture>

SwiftSMTP is a lightweight Swift package for sending email using SMTP. It provides a simple API to construct messages and send them via an SMTP server using SwiftNIO for networking and NIOSSL for TLS support.

This repository contains the `SwiftSMTP` library aimed at use from server and client-side Swift projects (macOS, iOS, etc.). It was created with multiplatform support in mind so it can be used on Apple platforms and on platforms where SwiftNIO runs (for example, Linux).

## Features

- Compose and send MIME-style email messages
- TLS (STARTTLS / implicit) support via NIOSSL
- Built on top of SwiftNIO for non-blocking networking
- Small, focused API surface (Client, Transport, Mail)

## Requirements

- Swift 5.9 or later
- Package declares support for: iOS 15+ and macOS 13+ (see `Package.swift`)
- Swift Package Manager (built into Swift)
- When deploying to Linux, ensure you have platform dependencies installed (for example, an OpenSSL implementation when using `NIOSSL`)

## Platform support

- Package targets: iOS 15+ and macOS 13+ (declared in `Package.swift`).
- SwiftNIO itself is primarily supported on macOS and Linux and is the foundation for server-side Swift networking.
- Many SwiftNIO modules and code paths also build on other Apple platforms (iOS/tvOS/watchOS) when the APIs they rely on are available, but availability of TLS backends (like `NIOSSL`) and certain low-level network features can vary by platform.

If you plan to run this package on Linux (server-side), make sure your environment has the required native libraries (OpenSSL or compatible) for `NIOSSL`. For Apple platforms, the package should build for the declared deployment targets, but test carefully if you change TLS/backends.

For the most up-to-date platform compatibility of SwiftNIO and related packages, refer to the upstream project documentation:

- SwiftNIO (https://github.com/apple/swift-nio)
- NIOSSL (https://github.com/apple/swift-nio-ssl)

## Installation

Add `swift-smtp` as a dependency to your `Package.swift`:

```swift
// Package.swift (snippet)
dependencies: [
    .package(url: "https://github.com/your-org/swift-smtp", from: "1.0.0")
]

targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "SwiftSMTP", package: "swift-smtp")
        ]
    )
]
```

Then run `swift build` in your project or open the package in Xcode.

> Note: Replace the package URL and version with the correct upstream repository and tag when publishing.

## Quick Start

Below is a minimal example of how to construct and send a message. The exact API names may vary; consult the sources under `Sources/SwiftSMTP` for the concrete types and initializer parameters.

```swift
import SwiftSMTP

let client = SMTPClient(host: "smtp.example.com", port: 587, username: "user", password: "password")

let mail = Mail(
    from: "sender@example.com",
    to: ["recipient@example.com"],
    subject: "Hello from SwiftSMTP",
    body: "This is a test message sent from SwiftSMTP."
)

Task {
    do {
        try await client.send(mail)
        print("Message sent")
    } catch {
        print("Failed sending message: \(error)")
    }
}
```

## Running Tests

This package includes a small test target. Run tests with SwiftPM:

```bash
swift test
```

Or run tests from Xcode by opening the package workspace.

## Contributing

Contributions are welcome. Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Add tests for any new behavior
4. Open a pull request with a clear description of the change

Please run `swift test` and ensure the project builds before submitting a PR.
