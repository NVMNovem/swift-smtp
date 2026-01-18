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
    
    private static let crlf = "\r\n"
    
    public let sender: Contact
    public let receivers: Receivers
    public let cc: Receivers?
    public let bcc: Receivers?
    public let replyTo: Contact?
    public let attachments: [Attachment]
    public let inlineImages: [InlineImage]
    public let subject: String
    public let body: Body
    
    public private(set) var priority: Priority? = nil

    fileprivate init(
        from sender: Contact,
        to receivers: Receivers,
        cc: Receivers? = nil,
        bcc: Receivers? = nil,
        replyTo: Contact? = nil,
        attachments: [Attachment] = [],
        inlineImages: [InlineImage] = [],
        subject: String,
        body: Body
    ) {
        self.sender = sender
        self.receivers = receivers
        self.cc = cc
        self.bcc = bcc
        self.replyTo = replyTo
        self.attachments = attachments
        self.inlineImages = inlineImages
        self.subject = subject
        self.body = body
    }
}

extension Mail: Sendable {}

extension Mail: Equatable {}

public extension Mail {
    
    init(
        from sender: Contact, to receiver: Contact, cc: Receivers? = nil, bcc: Receivers? = nil, replyTo: Contact? = nil,
        attachments: [Attachment] = [], subject: String, text: String
    ) {
        self.init(
            from: sender, to: .single(receiver), cc: cc, bcc: bcc, replyTo: replyTo,
            attachments: attachments, subject: subject, body: .plain(text)
        )
    }
    
    init(
        from sender: Contact, to receiver: Contact, cc: Receivers? = nil, bcc: Receivers? = nil, replyTo: Contact? = nil,
        attachments: [Attachment] = [], subject: String, html: () -> String
    ) {
        self.init(
            from: sender, to: .single(receiver), cc: cc, bcc: bcc, replyTo: replyTo,
            attachments: attachments, subject: subject, body: .html(html())
        )
    }
    
    init(
        from sender: Contact, to receivers: Contact..., cc: Receivers? = nil, bcc: Receivers? = nil, replyTo: Contact? = nil,
        attachments: [Attachment] = [], subject: String, text: String
    ) {
        self.init(
            from: sender, to: .multiple(receivers), cc: cc, bcc: bcc, replyTo: replyTo,
            attachments: attachments, subject: subject, body: .plain(text)
        )
    }
    
    init(
        from sender: Contact, to receivers: Contact..., cc: Receivers? = nil, bcc: Receivers? = nil, replyTo: Contact? = nil,
        attachments: [Attachment] = [], subject: String, html: () -> String
    ) {
        self.init(
            from: sender, to: .multiple(receivers), cc: cc, bcc: bcc, replyTo: replyTo,
            attachments: attachments, subject: subject, body: .html(html())
        )
    }
    
    init(
        from sender: Contact, to receivers: [Contact], cc: Receivers? = nil, bcc: Receivers? = nil, replyTo: Contact? = nil,
        attachments: [Attachment] = [], subject: String, text: String
    ) {
        self.init(
            from: sender, to: .multiple(receivers), cc: cc, bcc: bcc, replyTo: replyTo,
            attachments: attachments, subject: subject, body: .plain(text)
        )
    }
    
    init(
        from sender: Contact, to receivers: [Contact], cc: Receivers? = nil, bcc: Receivers? = nil, replyTo: Contact? = nil,
        attachments: [Attachment] = [], subject: String, html: () -> String
    ) {
        self.init(
            from: sender, to: .multiple(receivers), cc: cc, bcc: bcc, replyTo: replyTo,
            attachments: attachments, subject: subject, body: .html(html())
        )
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
        "\(headers)\r\n\r\n\(body.plainText)\r\n"
    }
    
    var headers: String {
        let sanitizedSubject = subject.sanitizedForSMTP()
        
        var headers = """
        From: \(sender.formatted())
        To: \(receivers.formatted())
        Subject: \(sanitizedSubject)
        Date: \(Date().rfc5322String())
        """

        if let cc {
            headers += "\nCc: \(cc.formatted())"
        }

        if let bcc {
            headers += "\nBcc: \(bcc.formatted())"
        }

        if let replyTo {
            headers += "\nReply-To: \(replyTo.formatted())"
        }
        
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
        
        return headers.replacingOccurrences(of: "\n", with: Mail.crlf)
    }
}
