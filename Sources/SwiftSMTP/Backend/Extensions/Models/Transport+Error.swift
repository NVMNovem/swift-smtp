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
    }
}

extension Transport.Error: LocalizedError {
    
    internal var errorDescription: String? {
        switch self {
        case .invalidChannel:
            return "Invalid channel."
        }
    }
}
