//
//  Mail.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 27/11/2025.
//

import Foundation

public struct Mail {
    
    public typealias Address = String
    
    public let sender: Contact
    public let receiver: Contact
    public let subject: String
    public let body: String

    public init(from senderAdress: Address, to receiverAddress: Address, subject: String, body: () -> String) {
        self.sender = Contact(email: senderAdress)
        self.receiver = Contact(email: receiverAddress)
        self.subject = subject
        self.body = body()
    }

    public init(from sender: Contact, to receiver: Contact, subject: String, body: () -> String) {
        self.sender = sender
        self.receiver = receiver
        self.subject = subject
        self.body = body()
    }

    /// Formatted RFC-like simple representation
    public func formatted() -> String {
        """
        From: \(sender.formatted())
        To: \(receiver.formatted())
        Subject: \(subject)

        \(body)
        """
    }
}

public extension Mail {
    
    struct Contact: Equatable {
        public let name: String?
        public let email: Address

        public init(_ name: String? = nil , email: Address) {
            self.name = name
            self.email = email
        }

        /// Formatted RFC-like simple representation
        public func formatted() -> String {
            if let name, !name.isEmpty {
                return "\(name) <\(email)>"
            } else {
                return email
            }
        }
    }
}
