//
//  Client+Error.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 27/11/2025.
//

import Foundation

public extension Client {
    
    enum Error: Swift.Error {
        case invalidResponse(String)
        case sendFailures([SendFailure])
    }

    struct SendFailure: Sendable {
        public let recipient: Mail.Contact
        public let error: Swift.Error

        public init(recipient: Mail.Contact, error: Swift.Error) {
            self.recipient = recipient
            self.error = error
        }
    }
}

extension Client.Error: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse(let response):
            return "Invalid response from server: \(response)"
        case .sendFailures(let failures):
            return "Failed to send to \(failures.count) recipient(s)."
        }
    }
}
