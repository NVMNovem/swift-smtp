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
        
        let name: String?
        let email: Address

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
    ///
    /// Sanitizes name and email to prevent SMTP injection attacks by removing
    /// carriage return and line feed characters that could be used to inject
    /// additional SMTP commands or headers.
    func formatted() -> String {
        let sanitizedEmail = email.sanitizedForSMTP()
        
        if let name, !name.isEmpty {
            let sanitizedName = name.sanitizedForSMTP()
            if sanitizedName.contains(where: { $0 == "," || $0 == "<" || $0 == ">" }) {
                return "\"\(sanitizedName)\" <\(sanitizedEmail)>"
            } else {
                return "\(sanitizedName) <\(sanitizedEmail)>"
            }
        } else {
            return "<\(sanitizedEmail)>"
        }
    }
}
