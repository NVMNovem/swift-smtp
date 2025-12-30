//
//  SMTPAuthenticationPolicy+Convenience.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 30/12/2025.
//

public extension SMTPAuthenticationPolicy {
    
    /// Creates an SMTP authentication policy using the LOGIN mechanism with the provided credentials.
    ///
    /// - Parameters:
    ///   - username: The username for SMTP authentication.
    ///   - password: The password for SMTP authentication.
    ///
    /// - Returns: An `SMTPAuthenticationPolicy` configured to use the LOGIN authentication method with the given credentials.
    ///
    static func login(username: String, password: String) -> SMTPAuthenticationPolicy {
        .login(SMTPCredentials(username: username, password: password))
    }
    
    /// Creates an SMTP authentication policy using the PLAIN mechanism with the provided credentials.
    ///
    /// - Parameters:
    ///   - username: The username for SMTP authentication.
    ///   - password: The password for SMTP authentication.
    ///
    /// - Returns: An `SMTPAuthenticationPolicy` configured to use the PLAIN authentication method with the given credentials.
    ///
    static func plain(username: String, password: String) -> SMTPAuthenticationPolicy {
        .plain(SMTPCredentials(username: username, password: password))
    }
}
