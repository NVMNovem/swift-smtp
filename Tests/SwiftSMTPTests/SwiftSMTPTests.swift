import Testing
@testable import SwiftSMTP

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

// MARK: - SMTP Injection Tests

@Test("Contact formatting sanitizes CRLF in email address")
func contactFormattingSanitizesEmailCRLF() {
    let maliciousEmail = "user@example.com\r\nRCPT TO:<attacker@evil.com>"
    let contact = Mail.Contact(email: maliciousEmail)
    let formatted = contact.formatted()
    
    // Should not contain carriage return or line feed
    #expect(!formatted.contains("\r"))
    #expect(!formatted.contains("\n"))
    #expect(formatted == "<user@example.comRCPT TO:<attacker@evil.com>>")
}

@Test("Contact formatting sanitizes CRLF in name")
func contactFormattingSanitizesNameCRLF() {
    let maliciousName = "John Doe\r\nBcc: attacker@evil.com"
    let contact = Mail.Contact(maliciousName, email: "john@example.com")
    let formatted = contact.formatted()
    
    // Should not contain carriage return or line feed
    #expect(!formatted.contains("\r"))
    #expect(!formatted.contains("\n"))
    #expect(formatted == "John DoeBcc: attacker@evil.com <john@example.com>")
}

@Test("Contact formatting sanitizes CRLF in quoted name")
func contactFormattingSanitizesQuotedNameCRLF() {
    let maliciousName = "Doe, John\r\nX-Malicious: header"
    let contact = Mail.Contact(maliciousName, email: "john@example.com")
    let formatted = contact.formatted()
    
    // Should not contain carriage return or line feed
    #expect(!formatted.contains("\r"))
    #expect(!formatted.contains("\n"))
    // Name with comma should be quoted
    #expect(formatted == "\"Doe, JohnX-Malicious: header\" <john@example.com>")
}

@Test("Mail headers sanitize CRLF in subject")
func mailHeadersSanitizeSubjectCRLF() {
    let maliciousSubject = "Important Message\r\nBcc: attacker@evil.com\r\nX-Priority: 1"
    let mail = Mail(
        from: "sender@example.com",
        to: "recipient@example.com",
        subject: maliciousSubject
    ) {
        "Hello, this is a test."
    }
    
    let formatted = mail.formatted()
    
    // Count occurrences of CRLF - should only have the legitimate ones
    let lines = formatted.components(separatedBy: "\n")
    
    // Check that subject line doesn't contain CRLF
    let subjectLine = lines.first { $0.hasPrefix("Subject:") }
    #expect(subjectLine != nil)
    
    if let subjectLine = subjectLine {
        // The malicious CRLF should be removed
        #expect(subjectLine == "Subject: Important MessageBcc: attacker@evil.comX-Priority: 1")
    }
    
    // The formatted output should not have injected headers as separate lines
    #expect(!formatted.contains("\nBcc: attacker@evil.com\n"))
    #expect(!lines.contains("Bcc: attacker@evil.com"))
}

@Test("Mail headers sanitize LF only in subject")
func mailHeadersSanitizeSubjectLF() {
    let maliciousSubject = "Important Message\nBcc: attacker@evil.com"
    let mail = Mail(
        from: "sender@example.com",
        to: "recipient@example.com",
        subject: maliciousSubject
    ) {
        "Hello, this is a test."
    }
    
    let formatted = mail.formatted()
    let lines = formatted.components(separatedBy: "\n")
    
    // Check that the Bcc header is not injected as a separate line
    #expect(!lines.contains("Bcc: attacker@evil.com"))
}

@Test("Multiple CRLF sequences are all sanitized")
func multipleCRLFSequencesSanitized() {
    let maliciousSubject = "Test\r\n\r\nBcc: a@evil.com\r\nCc: b@evil.com\r\n"
    let mail = Mail(
        from: "sender@example.com",
        to: "recipient@example.com",
        subject: maliciousSubject
    ) {
        "Body text"
    }
    
    let formatted = mail.formatted()
    
    // Should not contain the injected headers as separate lines
    let lines = formatted.components(separatedBy: "\n")
    #expect(!lines.contains("Bcc: a@evil.com"))
    #expect(!lines.contains("Cc: b@evil.com"))
}

@Test("Contact email with SMTP command injection attempt")
func contactEmailSMTPCommandInjection() {
    let maliciousEmail = "user@example.com\r\nMAIL FROM:<evil@attacker.com>\r\n"
    let contact = Mail.Contact(email: maliciousEmail)
    let formatted = contact.formatted()
    
    // Should strip CRLF to prevent SMTP command injection
    #expect(!formatted.contains("\r"))
    #expect(!formatted.contains("\n"))
    #expect(formatted == "<user@example.comMAIL FROM:<evil@attacker.com>>")
}

@Test("String sanitization extension removes CRLF")
func stringSanitizationRemovesCRLF() {
    let testString = "Hello\r\nWorld\rTest\nEnd"
    let sanitized = testString.sanitizedForSMTP()
    
    #expect(sanitized == "HelloWorldTestEnd")
    #expect(!sanitized.contains("\r"))
    #expect(!sanitized.contains("\n"))
}

@Test("String sanitization handles empty string")
func stringSanitizationHandlesEmpty() {
    let empty = ""
    let sanitized = empty.sanitizedForSMTP()
    
    #expect(sanitized == "")
}

@Test("String sanitization handles string with only CRLF")
func stringSanitizationHandlesOnlyCRLF() {
    let crlf = "\r\n\r\n"
    let sanitized = crlf.sanitizedForSMTP()
    
    #expect(sanitized == "")
}

