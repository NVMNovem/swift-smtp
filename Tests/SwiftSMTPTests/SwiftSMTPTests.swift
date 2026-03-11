import Testing
import Foundation

@testable import SwiftSMTP
import SwiftHTML

@Test(arguments: [SMTPCredentials(username: "", password: "")])
func sendHTML(credentials: SMTPCredentials) async throws {
    let client = Client(
        host: "smtp.office365.com",
        port: 587,
        heloName: domain(from: credentials.username) ?? "localhost",
        authentication: .login(credentials)
    )
    
    let mail = Mail(from: Mail.Contact(email: credentials.username), to: "", subject: "[SwiftHTML] Test mail") {
        HTMLDocument {
            Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                GridRowCell(alignment: .center) {
                    Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                        GridRowCell(height: 24) {
                            RawHTML("&nbsp;")
                        }
                        .style(.height("\(24)px"), .lineHeight("22px"), .fontSize("22px"), .background("#ffffff"), .borderTopLeftRadius("\(15)px"), .borderTopRightRadius("\(15)px"))
                    }
                    .style(.borderCollapse("collapse"), .width("\(600)px"), .maxWidth("\(600)px"))
                }
                .style(.background("#ABBBC7"), .padding("0 12px"))
                GridRowCell(alignment: .center) {
                    Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                        GridRowCell {
                            Text("This is an HTML mail.")
                                .style(.fontFamily("Arial, Helvetica, sans-serif"), .fontSize("16px"), .lineHeight("24px"), .color("#111827"))
                            Spacer(height: 16)
                            Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                                GridRowCell(alignment: .center) {
                                    Grid(role: .presentation, cellpadding: 0, cellspacing: 0, border: 0) {
                                        GridRowCell {
                                            Text(markdown: "**This is a test** Please ignore this mail.")
                                                .style(.fontFamily("Arial, Helvetica, sans-serif"), .fontSize("14px"), .lineHeight("20px"), .color("#7c2d12"))
                                        }
                                        .style(.padding("12px 12px"))
                                    }
                                    .style(.border("1px solid #fcd9b6"), .borderRadius("10px"), .background("#fffbf7"))
                                }
                            }
                            GridRowCell {
                                Text("This is an automated mail.")
                                    .style(.fontFamily("Arial, Helvetica, sans-serif"), .fontSize("12px"), .lineHeight("18px"), .color("#6b7280"))
                            }
                            .style(.padding("16px 24px"), .background("#f3f4f6"))
                        }
                        .style(.padding("0px 20px 20px 20px;"))
                    }
                    .style(.borderCollapse("collapse"), .width("\(600)px"), .maxWidth("\(600)px"), .background("#ffffff"), .borderBottomLeftRadius("\(15)px"), .borderBottomRightRadius("\(15)px"), .overflow("hidden"))
                }
                .style(.background("#D1DAE0"), .padding("0 12px 50px 12px"))
            }
            .style(.borderCollapse("collapse"), .width("100%"), .background("#D1DAE0"))
        } head: {
            Meta(.charset("utf-8"))
            Meta(.name("viewport", content: "width=device-width,initial-scale=1"))
            Title("SwiftHTML")
        }
        .language("en")
        .style(.margin("0"), .padding("0"), .background("#D1DAE0"))
    }
    
    do {
        try await client.send(mail)
        #expect(Bool(true))
    } catch {
        #expect(Bool(false))
    }
}

@Test(arguments: [SMTPCredentials(username: "", password: "")])
func sendText(credentials: SMTPCredentials) async throws {
    let client = Client(
        host: "smtp.office365.com",
        port: 587,
        heloName: domain(from: credentials.username) ?? "localhost",
        authentication: .login(credentials)
    )
    
    let mail = Mail(from: Mail.Contact(email: credentials.username), to: "", subject: "[SwiftHTML] Test mail", text: "Dit is standaard text")
    
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
