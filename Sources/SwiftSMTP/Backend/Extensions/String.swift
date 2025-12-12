//
//  String.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 12/12/2025.
//

extension String {
    
    /// Sanitizes a string by removing carriage return and line feed characters
    /// to prevent SMTP injection and email header injection attacks.
    ///
    /// This method strips `\r` (carriage return) and `\n` (line feed) characters
    /// which could be used to inject additional SMTP commands or email headers.
    ///
    /// - Returns: A sanitized string with all CR and LF characters removed.
    internal func sanitizedForSMTP() -> String {
        self.replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}
