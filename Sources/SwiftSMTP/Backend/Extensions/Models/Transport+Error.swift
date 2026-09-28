//
//  Transport+Error.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 27/11/2025.
//

import Foundation

internal extension Transport {

    enum Error: Swift.Error {
        case invalidChannel
        case invalidResponse
        case authenticationFailed
        case connectionClosed(Swift.Error?)
        case timeout(Duration)
    }
}

extension Transport.Error: LocalizedError {

    internal var errorDescription: String? {
        switch self {
        case .invalidChannel:
            return "Invalid channel."
        case .invalidResponse:
            return "Invalid response from server."
        case .authenticationFailed:
            return "Authentication failed."
        case .connectionClosed(let error):
            if let error {
                return "Connection closed: \(error.localizedDescription)"
            }
            return "Connection closed by server."
        case .timeout(let duration):
            return "No response from server within \(duration)."
        }
    }
}
