//
//  Date.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 30/12/2025.
//

import Foundation

extension Date {
    
    /// Returns the date formatted as an RFC 2822 string.
    ///
    /// This is commonly used in Internet email headers and similar contexts.
    ///
    /// The format used is: `"EEE, dd MMM yyyy HH:mm:ss Z"`, for example: `"Mon, 30 Dec 2025 17:45:00 +0000"`.
    ///
    /// - Returns: A `String` representation of the date in RFC 2822 format, using the US POSIX locale to ensure consistency.
    internal func rfc2822String() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.string(from: self)
    }
}
