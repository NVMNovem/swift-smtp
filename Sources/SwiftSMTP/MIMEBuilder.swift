//
//  MIMEBuilder.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 05/01/2026.
//

import Foundation

public enum MIMEBuilder {
    private static let crlf = "\r\n"

    private struct MIMEContainer {
        let headers: [String]
        let body: Data
    }

    public static func build(_ mail: Mail, date: Date = Date(), messageIDDomain: String) -> Data {
        var buffer = Data()

        buffer.append("From: \(formatAddress(mail.sender))\(crlf)")
        buffer.append("To: \(formatAddresses(mail.receivers.all))\(crlf)")

        if let cc = mail.cc {
            buffer.append("Cc: \(formatAddresses(cc.all))\(crlf)")
        }

        if let reply = mail.replyTo {
            buffer.append("Reply-To: \(formatAddress(reply))\(crlf)")
        }

        buffer.append("Subject: \(encodeSubject(mail.subject))\(crlf)")
        buffer.append("Date: \(rfc5322Date(date))\(crlf)")
        buffer.append("Message-ID: <\(UUID().uuidString)@\(sanitizeHeaderValue(messageIDDomain))>\(crlf)")
        buffer.append("MIME-Version: 1.0\(crlf)")
        priorityHeaders(for: mail.priority).forEach { buffer.append("\($0)\(crlf)") }

        let bodyContainer = buildBody(for: mail)
        bodyContainer.headers.forEach { buffer.append("\($0)\(crlf)") }

        buffer.append(crlf)
        buffer.append(bodyContainer.body)

        if !buffer.hasSuffix(crlf) {
            buffer.append(crlf)
        }

        return buffer
    }

    private static func buildBody(for mail: Mail) -> MIMEContainer {
        let mainPart: MIMEContainer

        switch mail.body {
        case .plain(let text):
            mainPart = buildTextPart(content: text, contentType: "text/plain")
        case .html(let html):
            if mail.inlineImages.isEmpty {
                mainPart = buildTextPart(content: html, contentType: "text/html")
            } else {
                mainPart = buildRelated(html: html, inlineImages: mail.inlineImages)
            }
        case .alternative(let plain, let html):
            if mail.inlineImages.isEmpty {
                mainPart = buildAlternative(plain: plain, html: html)
            } else {
                mainPart = buildAlternativeWithRelated(plain: plain, html: html, inlineImages: mail.inlineImages)
            }
        }

        let attachments: [Mail.Attachment]
        if case .plain = mail.body, !mail.inlineImages.isEmpty {
            attachments = mail.attachments + mail.inlineImages.map {
                Mail.Attachment(filename: $0.filename, mimeType: $0.mimeType, data: $0.data)
            }
        } else {
            attachments = mail.attachments
        }

        guard !attachments.isEmpty else { return mainPart }

        return buildMixed(bodyPart: mainPart, attachments: attachments)
    }

    private static func buildAlternative(plain: String, html: String) -> MIMEContainer {
        let boundary = boundaryIdentifier()
        let plainPart = buildTextPart(content: plain, contentType: "text/plain")
        let htmlPart = buildTextPart(content: html, contentType: "text/html")
        return buildMultipart(type: "multipart/alternative", boundary: boundary, parts: [plainPart, htmlPart])
    }

    private static func buildAlternativeWithRelated(plain: String, html: String, inlineImages: [Mail.InlineImage]) -> MIMEContainer {
        let altBoundary = boundaryIdentifier()
        let relatedBoundary = boundaryIdentifier()

        let plainPart = buildTextPart(content: plain, contentType: "text/plain")
        let htmlPart = buildTextPart(content: html, contentType: "text/html")
        let inlineParts = inlineImages.map { buildInlinePart(image: $0) }

        let relatedPart = buildMultipart(type: "multipart/related", boundary: relatedBoundary, parts: [htmlPart] + inlineParts)

        return buildMultipart(type: "multipart/alternative", boundary: altBoundary, parts: [plainPart, relatedPart])
    }

    private static func buildRelated(html: String, inlineImages: [Mail.InlineImage]) -> MIMEContainer {
        let boundary = boundaryIdentifier()
        let htmlPart = buildTextPart(content: html, contentType: "text/html")
        let inlineParts = inlineImages.map { buildInlinePart(image: $0) }
        return buildMultipart(type: "multipart/related", boundary: boundary, parts: [htmlPart] + inlineParts)
    }

    private static func buildMixed(bodyPart: MIMEContainer, attachments: [Mail.Attachment]) -> MIMEContainer {
        let boundary = boundaryIdentifier()
        let attachmentParts = attachments.map { buildAttachmentPart(attachment: $0) }
        let parts = [bodyPart] + attachmentParts
        return buildMultipart(type: "multipart/mixed", boundary: boundary, parts: parts)
    }

    private static func buildMultipart(type: String, boundary: String, parts: [MIMEContainer]) -> MIMEContainer {
        var body = Data()

        for part in parts {
            body.append("--\(boundary)\(crlf)")
            body.append(render(part))
        }

        body.append("--\(boundary)--\(crlf)")

        return MIMEContainer(
            headers: ["Content-Type: \(type); boundary=\"\(boundary)\""],
            body: body
        )
    }

    private static func buildTextPart(content: String, contentType: String) -> MIMEContainer {
        let normalized = normalizeNewlines(content)

        let body = "\(encodeQuotedPrintable(normalized))\(crlf)".data(using: .utf8) ?? Data()

        return MIMEContainer(
            headers: [
                "Content-Type: \(contentType); charset=\"utf-8\"",
                "Content-Transfer-Encoding: quoted-printable"
            ],
            body: body
        )
    }

    private static func buildInlinePart(image: Mail.InlineImage) -> MIMEContainer {
        let body = "\(encodeBase64(image.data))\(crlf)".data(using: .utf8) ?? Data()

        return MIMEContainer(
            headers: [
                "Content-Type: \(image.mimeType); name=\"\(sanitizeHeaderValue(image.filename))\"",
                "Content-Transfer-Encoding: base64",
                "Content-Disposition: inline; filename=\"\(sanitizeHeaderValue(image.filename))\"",
                "Content-ID: <\(sanitizeHeaderValue(image.contentID))>"
            ],
            body: body
        )
    }

    private static func buildAttachmentPart(attachment: Mail.Attachment) -> MIMEContainer {
        let body = "\(encodeBase64(attachment.data))\(crlf)".data(using: .utf8) ?? Data()

        return MIMEContainer(
            headers: [
                "Content-Type: \(attachment.mimeType); name=\"\(sanitizeHeaderValue(attachment.filename))\"",
                "Content-Transfer-Encoding: base64",
                "Content-Disposition: attachment; filename=\"\(sanitizeHeaderValue(attachment.filename))\""
            ],
            body: body
        )
    }

    private static func render(_ container: MIMEContainer) -> Data {
        var data = Data()
        container.headers.forEach { data.append("\($0)\(crlf)") }
        data.append(crlf)
        data.append(container.body)
        return data
    }

    private static func encodeQuotedPrintable(_ string: String) -> String {
        let bytes = Array(string.utf8)
        var result = ""
        var lineLength = 0
        var index = 0

        while index < bytes.count {
            let byte = bytes[index]

            if byte == 13, index + 1 < bytes.count, bytes[index + 1] == 10 {
                result.append("\r\n")
                lineLength = 0
                index += 2
                continue
            }

            let encoded: String
            if (33...126).contains(byte) && byte != 61 {
                encoded = String(UnicodeScalar(byte))
            } else if byte == 9 || byte == 32 {
                let isLineEnd = (index + 1 >= bytes.count) || bytes[index + 1] == 13
                if isLineEnd {
                    encoded = String(format: "=%02X", byte)
                } else {
                    encoded = String(UnicodeScalar(byte))
                }
            } else {
                encoded = String(format: "=%02X", byte)
            }

            if lineLength + encoded.count > 75 {
                result.append("=\r\n")
                lineLength = 0
            }

            result.append(encoded)
            lineLength += encoded.count
            index += 1
        }

        return result
    }

    private static func encodeBase64(_ data: Data) -> String {
        let encoded = data.base64EncodedString()
        var lines: [String] = []
        var start = encoded.startIndex

        while start < encoded.endIndex {
            let end = encoded.index(start, offsetBy: 76, limitedBy: encoded.endIndex) ?? encoded.endIndex
            lines.append(String(encoded[start..<end]))
            start = end
        }

        return lines.joined(separator: crlf)
    }

    private static func boundaryIdentifier() -> String {
        "swift-smtp-boundary-\(UUID().uuidString)"
    }

    private static func formatAddresses(_ addresses: [Mail.Contact]) -> String {
        addresses.map { formatAddress($0) }.joined(separator: ", ")
    }

    private static func formatAddress(_ address: Mail.Contact) -> String {
        let sanitizedEmail = sanitizeHeaderValue(address.email)
        if let name = address.name, !name.isEmpty {
            let sanitizedName = sanitizeHeaderValue(name).replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(sanitizedName)\" <\(sanitizedEmail)>"
        } else {
            return "<\(sanitizedEmail)>"
        }
    }

    private static func sanitizeHeaderValue(_ value: String) -> String {
        value.replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "")
    }

    private static func encodeSubject(_ subject: String) -> String {
        let sanitized = sanitizeHeaderValue(subject)
        if sanitized.canBeConverted(to: .ascii) {
            return sanitized
        }

        guard let data = sanitized.data(using: .utf8) else { return sanitized }
        let encoded = data.base64EncodedString()
        return "=?UTF-8?B?\(encoded)?="
    }

    private static func rfc5322Date(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        return formatter.string(from: date)
    }

    private static func priorityHeaders(for priority: Priority?) -> [String] {
        switch priority {
        case .high:
            return [
                "X-Priority: 1 (Highest)",
                "X-MSMail-Priority: High",
                "Importance: High"
            ]
        case .low:
            return [
                "X-Priority: 5 (Lowest)",
                "Importance: Low"
            ]
        default:
            return []
        }
    }

    private static func normalizeNewlines(_ text: String) -> String {
        let collapsed = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        return collapsed.replacingOccurrences(of: "\n", with: "\r\n")
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }

    func hasSuffix(_ string: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return count >= data.count && suffix(data.count) == data
    }
}
