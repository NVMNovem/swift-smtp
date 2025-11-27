//
//  Mail.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 27/11/2025.
//

import Foundation

public struct Mail {
    
    public let from: String
    public let to: String
    public let subject: String
    public let body: String

    public init(from: String, to: String, subject: String, body: String) {
        self.from = from
        self.to = to
        self.subject = subject
        self.body = body
    }

    public func formatted() -> String {
        """
        From: \(from)
        To: \(to)
        Subject: \(subject)

        \(body)
        """
    }
}
