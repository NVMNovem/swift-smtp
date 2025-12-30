//
//  Mail.swift
//  SwiftSMTP
//
//  Created by Damian Van de Kauter on 27/11/2025.
//

import Foundation

/// Represents an email message, including sender, recipient, subject, and body.
///
/// The `Mail` struct provides a simple model for constructing an email message,
/// including sender and receiver information, email subject, and the body text.
/// Use one of the initializers to create a new `Mail` either by providing
/// contact objects or just email address strings for sender and recipient.
///
/// Example usage:
/// ```swift
/// // Using address strings
/// let mail = Mail(from: "alice@example.com", to: "bob@example.com", subject: "Hello") {
///     "How are you?"
/// }
///
///
/// // Using Contact objects
/// let sender = Mail.Contact("Alice", email: "alice@example.com")
/// let recipient = Mail.Contact("Bob", email: "bob@example.com")
/// let mail = Mail(from: sender, to: recipient, subject: "Hello") {
///     "How are you?"
/// }
/// ```
///
/// - Note: The body is provided as a closure, allowing for deferred evaluation.
///
public struct Mail {
    
    public let sender: Contact
    public let receivers: Receivers
    public let subject: String
    public let body: String
    
    public private(set) var priority: Priority? = nil

    public init(from sender: Contact, to receivers: [Contact], subject: String, body: () -> String) {
        self.sender = sender
        self.receivers = .multiple(receivers)
        self.subject = subject
        self.body = body()
    }

    public init(from senderAddress: Address, to receiverAddresses: [Address], subject: String, body: () -> String) {
        self.sender = Contact(email: senderAddress)
        self.receivers = .multiple(receiverAddresses.map { Contact(email: $0) })
        self.subject = subject
        self.body = body()
    }
}

extension Mail: Sendable {}

public extension Mail {
    
    init(from sender: Contact, to receiver: Contact, subject: String, body: () -> String) {
        self.init(from: sender, to: [receiver], subject: subject, body: body)
    }
    
    init(from senderAddress: Address, to receiverAddress: Address, subject: String, body: () -> String) {
        self.init(from: senderAddress, to: [receiverAddress], subject: subject, body: body)
    }

    init(from sender: Contact, to receivers: Contact..., subject: String, body: () -> String) {
        self.init(from: sender, to: Array(receivers), subject: subject, body: body)
    }

    init(from senderAddress: Address, to receiverAddresses: Address..., subject: String, body: () -> String) {
        self.init(from: senderAddress, to: Array(receiverAddresses), subject: subject, body: body)
    }
}

public extension Mail {
    
    mutating func setPriority(_ priority: Priority) {
        self.priority = priority
    }
}

// MARK: - Internal Formatting
internal extension Mail {
    
    /// Formatted RFC-like simple representation
    func formatted() -> String {
        """
        \(headers)
        
        \(body)
        """
    }
    
    var headers: String {
        let sanitizedSubject = subject.sanitizedForSMTP()
        
        var headers = """
        From: \(sender.formatted())
        To: \(receivers.formatted())
        Subject: \(sanitizedSubject)
        Date: \(Date().rfc2822String())
        """
        
        switch priority {
        case .high:
            headers += """
            
            X-Priority: 1 (Highest)
            X-MSMail-Priority: High
            Importance: High
            """
        case .low:
            headers += """
            
            X-Priority: 5 (Lowest)
            Importance: Low
            """
        default: break
        }
        
        return headers
    }
}
