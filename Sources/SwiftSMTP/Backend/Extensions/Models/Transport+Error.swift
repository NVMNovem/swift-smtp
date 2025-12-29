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
        }
    }
}
