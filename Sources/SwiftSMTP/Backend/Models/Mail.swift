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
    
    /// A typealias representing an email address as a `String`.
    ///
    /// `Address` is used throughout the `Mail` structure to clearly indicate locations
    /// where an email address is expected or required. This improves readability and 
    /// helps distinguish email address values from other `String` types.
    ///
    /// Example:
    /// ```swift
    /// let sender: Mail.Address = "alice@example.com"
    /// let recipient: Mail.Address = "bob@example.com"
    /// ```
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
    internal func formatted() -> String {
        """
        From: \(sender.formatted())
        To: \(receiver.formatted())
        Subject: \(subject)

        \(body)
        """
    }
}

extension Mail: Sendable {}

public extension Mail {
    
    /// Represents an email contact, containing an optional name and a required email address.
    /// 
    /// Use `Contact` to identify senders or recipients in a `Mail` object. 
    /// The `name` can be `nil` or empty if only the email should be used.
    /// 
    /// - Parameters:
    ///   - name: The display name for this contact (optional).
    ///   - email: The email address associated with this contact (required).
    ///
    /// Example usage:
    /// ```swift
    /// let recipient = Mail.Contact("Jane Doe", email: "jane@example.com")
    /// let sender = Mail.Contact(email: "noreply@service.com")
    /// ```
    struct Contact {
        
        private let name: String?
        private let email: Address

        public init(_ name: String? = nil , email: Address) {
            self.name = name
            self.email = email
        }

        /// Formatted RFC-like simple representation
        internal func formatted() -> String {
            if let name, !name.isEmpty {
                return "\(name) <\(email)>"
            } else {
                return email
            }
        }
    }
}

extension Mail.Contact: Sendable {}

extension Mail.Contact: Equatable, Hashable {}
    

