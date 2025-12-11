//
//  MailAddress.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 11/12/2025.
//

public extension Mail {
    
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
    typealias Address = String
}
