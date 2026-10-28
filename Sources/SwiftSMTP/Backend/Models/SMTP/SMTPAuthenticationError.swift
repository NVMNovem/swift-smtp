import Foundation

/// An unexpected SMTP reply during LOGIN or PLAIN authentication.
/// Only sanitized diagnostics are retained; credentials and raw replies are never stored.
public struct SMTPAuthenticationError: Error, Sendable, LocalizedError, CustomStringConvertible {
    public enum Mechanism: String, Sendable {
        case login = "LOGIN"
        case plain = "PLAIN"
    }

    public enum Stage: String, Sendable {
        /// The reply to AUTH LOGIN, before sending a username.
        case initialCommand = "initial command"
        /// The reply after sending the LOGIN username.
        case usernameChallenge = "username challenge"
        /// The reply after sending the LOGIN password or PLAIN credentials.
        case credentialsVerification = "credentials verification"
    }

    public let mechanism: Mechanism
    public let stage: Stage
    public let responseCode: Int
    /// The first enhanced status code at the start of a reply line, if present.
    public let enhancedStatusCode: String?
    /// A single-line, ASCII diagnostic excerpt, limited to 512 UTF-8 bytes.
    /// Unrecognized text is replaced with `[redacted]`; this is not a raw server reply.
    public let responseText: String

    public var description: String {
        let enhanced = enhancedStatusCode.map { " (\($0))" } ?? ""
        return "SMTP \(mechanism.rawValue) authentication failed at \(stage.rawValue): \(responseCode)\(enhanced). \(responseText)"
    }

    public var errorDescription: String? { description }

    internal init(
        mechanism: Mechanism,
        stage: Stage,
        response: (code: Int, lines: [String]),
        username: String,
        password: String
    ) {
        self.mechanism = mechanism
        self.stage = stage
        self.responseCode = response.code
        let bodies = response.lines.map { String($0.dropFirst(4)) }
        self.enhancedStatusCode = bodies.lazy.compactMap { body in
            let first = String(body.prefix(while: { !$0.isWhitespace }))
            return first.range(of: #"^[245]\.[0-9]{1,3}\.[0-9]{1,3}$"#, options: .regularExpression) != nil ? first : nil
        }.first

        // Redact before truncation, so a credential crossing the excerpt boundary
        // cannot leave a visible prefix. These values are used transiently only.
        let plain = "\u{0}\(username)\u{0}\(password)"
        let secrets = [username, password, plain].flatMap {
            [$0, Data($0.utf8).base64EncodedString(), Data($0.utf8).base64EncodedString().replacingOccurrences(of: "=", with: "")]
        }.filter { !$0.isEmpty }.sorted { $0.count > $1.count }

        var excerpt = ""
        for body in bodies {
            var text = body
            for secret in secrets {
                text = text.replacingOccurrences(of: secret, with: "[redacted]", options: .caseInsensitive)
            }
            // An echoed command may contain any SASL payload, including an unknown token.
            text = text.replacingOccurrences(of: #"(?i)\bAUTH\b[^\r\n]*"#, with: "[redacted]", options: .regularExpression)
            // Never copy arbitrary server tokens, identifiers, addresses, Base64 or
            // control characters. A vocabulary is intentionally more conservative
            // than trying to recognize every possible secret with a denylist.
            let words = text.split(whereSeparator: { $0.isWhitespace }).map { token -> String in
                let word = String(token).trimmingCharacters(in: CharacterSet(charactersIn: ".,:;!?()[]"))
                return Self.diagnosticWords.contains(word.lowercased()) ? word : "[redacted]"
            }
            for word in words {
                let addition = (excerpt.isEmpty ? "" : " ") + word
                guard excerpt.utf8.count + addition.utf8.count <= 509 else {
                    self.responseText = excerpt + "..."
                    return
                }
                excerpt += addition
            }
        }
        self.responseText = excerpt
    }

    private static let diagnosticWords: Set<String> = [
        "a", "access", "account", "allowed", "an", "and", "are", "authentication",
        "authorization", "available", "bad", "basic", "blocked", "by", "cannot",
        "client", "command", "connection", "contact", "credentials", "denied",
        "disabled", "enabled", "encryption", "error", "expired", "failed", "failure",
        "for", "from", "in", "incorrect", "invalid", "is", "limit", "locked", "login",
        "many", "mechanism", "missing", "not", "of", "on", "or", "password", "permitted",
        "plain", "please", "policy", "rejected", "required", "requires", "response",
        "retry", "security", "server", "service", "smtp", "starttls", "successful",
        "support", "supported", "temporarily", "temporary", "the", "tls", "to", "too",
        "try", "unavailable", "unknown", "unsupported", "user", "username", "verification"
    ]
}
