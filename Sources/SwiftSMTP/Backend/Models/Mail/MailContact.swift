//
//  Contact.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 11/12/2025.
//

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
    }
}

extension Mail.Contact: Sendable {}

extension Mail.Contact: Equatable, Hashable {}

// MARK: - Internal Formatting
internal extension Mail.Contact {
    
    /// Formatted RFC-like simple representation
    func formatted() -> String {
        if let name, !name.isEmpty {
            if name.contains(where: { $0 == "," || $0 == "<" || $0 == ">" }) {
                return "\"\(name)\" <\(email)>"
            } else {
                return "\(name) <\(email)>"
            }
        } else {
            return "<\(email)>"
        }
    }
}

