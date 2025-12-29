//
//  SMTPResponse.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 29/12/2025.
//

internal struct SMTPResponse {
    
    let code: Int
    let lines: [String]
    
    internal init(code: Int, lines: [String]) {
        self.code = code
        self.lines = lines
    }
}

extension SMTPResponse: Sendable {}
