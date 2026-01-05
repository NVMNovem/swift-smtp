import Testing
import Foundation
@testable import SwiftSMTP

@Test
func sendHTML(credentials: SMTPCredentials) async throws {
    let client = Client(
        host: "smtp.office365.com",
        port: 587,
        heloName: domain(from: credentials.username) ?? "localhost",
        authentication: .login(credentials)
    )
    
    let mail = Mail(
        from: Mail.Contact(email: credentials.username), to: Mail.Contact(email: "vdkdamian@gmail.com"),
        subject: "Test html", htmlBody: {
        """
        <!doctype html>
        <html lang="en">
        <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width,initial-scale=1" />
        <meta name="x-apple-disable-message-reformatting" />
        <meta name="color-scheme" content="light dark" />
        <meta name="supported-color-schemes" content="light dark" />
        <title>Test Email</title>
        </head>
        
        <body style="margin:0; padding:0; background:#f6f7fb;">
        <!-- Preheader (hidden preview text in many clients) -->
        <div style="display:none; max-height:0; overflow:hidden; opacity:0; mso-hide:all;">
        This is a test email from Funico. If you can read this, HTML is working.
        </div>
        
        <!-- Gmail iOS/Android spacing hack -->
        <div style="display:none; white-space:nowrap; font:15px/1px monospace;">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </div>
        
        <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="100%"
        style="border-collapse:collapse; background:#f6f7fb;">
        <tr>
        <td align="center" style="padding:24px 12px;">
          <!-- Container -->
          <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="600"
            style="width:600px; max-width:600px; border-collapse:collapse; background:#ffffff; border-radius:12px; overflow:hidden;">
            
            <!-- Header -->
            <tr>
              <td style="padding:20px 24px; background:#111827;">
                <div style="font-family:Arial, Helvetica, sans-serif; font-size:18px; line-height:24px; color:#ffffff; font-weight:bold;">
                  Funico — Test Email
                </div>
                <div style="font-family:Arial, Helvetica, sans-serif; font-size:13px; line-height:18px; color:#c7d2fe; margin-top:4px;">
                  HTML rendering + basic layout check
                </div>
              </td>
            </tr>
        
            <!-- Body -->
            <tr>
              <td style="padding:24px;">
                <div style="font-family:Arial, Helvetica, sans-serif; font-size:16px; line-height:24px; color:#111827;">
                  Hi,<br /><br />
                  This is a simple HTML email for testing. It includes:
                  <ul style="margin:12px 0 0 20px; padding:0;">
                    <li>Inline styles (best compatibility)</li>
                    <li>Table layout (works in Outlook)</li>
                    <li>A button and a few text styles</li>
                  </ul>
                </div>
        
                <div style="height:18px; line-height:18px;">&nbsp;</div>
        
                <!-- Button -->
                <table role="presentation" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;">
                  <tr>
                    <td align="center" bgcolor="#2563eb" style="border-radius:10px;">
                      <a href="https://example.com"
                         style="display:inline-block; padding:12px 16px; font-family:Arial, Helvetica, sans-serif;
                                font-size:15px; line-height:18px; color:#ffffff; text-decoration:none; font-weight:bold;">
                        Open Example
                      </a>
                    </td>
                  </tr>
                </table>
        
                <div style="height:18px; line-height:18px;">&nbsp;</div>
        
                <div style="font-family:Arial, Helvetica, sans-serif; font-size:14px; line-height:20px; color:#374151;">
                  If the button doesn’t work, copy &amp; paste this link:
                  <br />
                  <a href="https://example.com" style="color:#2563eb; text-decoration:underline;">
                    https://example.com
                  </a>
                </div>
              </td>
            </tr>
        
            <!-- Footer -->
            <tr>
              <td style="padding:16px 24px; background:#f3f4f6;">
                <div style="font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px; color:#6b7280;">
                  Sent by Funico • This is a test message.<br />
                  <span style="color:#9ca3af;">If you received this by accident, you can ignore it.</span>
                </div>
              </td>
            </tr>
        
          </table>
        
          <!-- Small note below -->
          <div style="font-family:Arial, Helvetica, sans-serif; font-size:11px; line-height:16px; color:#9ca3af; margin-top:10px;">
            Tip: test in Gmail, Outlook, Apple Mail, and a mobile client.
          </div>
        </td>
        </tr>
        </table>
        </body>
        </html>
        """
        }
    )
    
    do {
        try await client.send(mail)
        #expect(Bool(true))
    } catch {
        #expect(Bool(false))
    }
}

@Test
func sendText(credentials: SMTPCredentials) async throws {
    let client = Client(
        host: "smtp.office365.com",
        port: 587,
        heloName: domain(from: credentials.username) ?? "localhost",
        authentication: .login(credentials)
    )
    
    let mail = Mail(
        from: Mail.Contact(email: credentials.username), to: Mail.Contact(email: "vdkdamian@gmail.com"),
        subject: "Test text", body: {
        """
        Dit is standaard text
        """
        }
    )
    
    do {
        try await client.send(mail)
        #expect(Bool(true))
    } catch {
        #expect(Bool(false))
    }
}

fileprivate func domain(from email: String) -> String? {
    guard let atIndex = email.lastIndex(of: "@") else { return nil }
    return String(email[email.index(after: atIndex)...])
}
