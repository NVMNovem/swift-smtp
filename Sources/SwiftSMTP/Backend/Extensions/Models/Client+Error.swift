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
    }
}

extension Client.Error: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse(let response):
            return "Invalid response from server: \(response)"
        }
    }
}
