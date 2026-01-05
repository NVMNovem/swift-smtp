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
    public let cc: [Contact]
    public let bcc: [Contact]
    public let replyTo: Contact?
    public let subject: String
    public let body: Body
    public let attachments: [Attachment]
    public let inlineImages: [InlineImage]
    
    public private(set) var priority: Priority? = nil

    public init(
        from sender: Contact,
        to receivers: [Contact],
        subject: String,
        body: Body,
        cc: [Contact] = [],
        bcc: [Contact] = [],
        attachments: [Attachment] = [],
        inlineImages: [InlineImage] = [],
        replyTo: Contact? = nil
    ) {
        self.sender = sender
        self.receivers = .multiple(receivers)
        self.cc = cc
        self.bcc = bcc
        self.replyTo = replyTo
        self.subject = subject
        self.body = body
        self.attachments = attachments
        self.inlineImages = inlineImages
    }

    public init(
        from sender: Contact,
        to receivers: [Contact],
        subject: String,
        plainText: String,
        html: String? = nil,
        cc: [Contact] = [],
        bcc: [Contact] = [],
        attachments: [Attachment] = [],
        inlineImages: [InlineImage] = [],
        replyTo: Contact? = nil
    ) {
        let body: Body = html.map { .alternative(plain: plainText, html: $0) } ?? .plain(plainText)
        self.init(
            from: sender,
            to: receivers,
            subject: subject,
            body: body,
            cc: cc,
            bcc: bcc,
            attachments: attachments,
            inlineImages: inlineImages,
            replyTo: replyTo
        )
    }

    public init(
        from senderAddress: Address,
        to receiverAddresses: [Address],
        subject: String,
        plainText: String,
        html: String? = nil,
        cc: [Address] = [],
        bcc: [Address] = [],
        attachments: [Attachment] = [],
        inlineImages: [InlineImage] = [],
        replyTo: Address? = nil
    ) {
        self.init(
            from: Contact(email: senderAddress),
            to: receiverAddresses.map { Contact(email: $0) },
            subject: subject,
            plainText: plainText,
            html: html,
            cc: cc.map { Contact(email: $0) },
            bcc: bcc.map { Contact(email: $0) },
            attachments: attachments,
            inlineImages: inlineImages,
            replyTo: replyTo.map { Contact(email: $0) }
        )
    }
}

extension Mail: Sendable {}

extension Mail: Equatable {}

public extension Mail {
    
    init(from sender: Contact, to receiver: Contact, subject: String, body: () -> String) {
        self.init(from: sender, to: [receiver], subject: subject, plainText: body())
    }
    
    init(from sender: Contact, to receiver: Contact, subject: String, htmlBody: () -> String) {
        self.init(from: sender, to: [receiver], subject: subject, body: .html(htmlBody()))
    }
    
    init(from senderAddress: Address, to receiverAddress: Address, subject: String, body: () -> String) {
        self.init(from: senderAddress, to: [receiverAddress], subject: subject, plainText: body())
    }
    
    init(from senderAddress: Address, to receiverAddress: Address, subject: String, htmlBody: () -> String) {
        self.init(
            from: Contact(email: senderAddress),
            to: [Contact(email: receiverAddress)],
            subject: subject,
            body: .html(htmlBody())
        )
    }

    init(from sender: Contact, to receivers: Contact..., subject: String, body: () -> String) {
        self.init(from: sender, to: Array(receivers), subject: subject, plainText: body())
    }

    init(from senderAddress: Address, to receiverAddresses: Address..., subject: String, body: () -> String) {
        self.init(from: senderAddress, to: Array(receiverAddresses), subject: subject, plainText: body())
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

        if !cc.isEmpty {
            headers += "\nCc: \(cc.map { $0.formatted() }.joined(separator: ", "))"
        }

        if !bcc.isEmpty {
            headers += "\nBcc: \(bcc.map { $0.formatted() }.joined(separator: ", "))"
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
