//
//  SwiftHTMLTests.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

import Testing
import Foundation
@testable import SwiftHTML
import SwiftSMTP

@Test
func renderHTML1() async throws {
    let cardCornerRadius: Int = 16
    let cardInnerMargin: Int = 24
    let contentWidth: Int = 600
    
    let doc = HTMLDocument {
        Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
            GridRow {
                GridCell(alignment: .center) {
                    Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                        GridRow {
                            GridCell(alignment: .center) {
                                Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                                    GridRow {
                                        GridCell(alignment: .leading, valign: "middle") {
                                            Image(src: "https://funico.international/_BE/images/layout/Logo_Funico_wit.png", alt: "Funico", width: 120)
                                                .style("display:block; border:0; outline:none; text-decoration:none; height:auto;")
                                        }
                                    }
                                }
                                .style("border-collapse:collapse; width:\(contentWidth - cardInnerMargin)px; max-width:\(contentWidth - cardInnerMargin)px;")
                            }
                            .style("padding:14px 12px;")
                        }
                    }
                    .style("border-collapse:collapse;")
                }
                .style("background:#2C5573;")
            }
            GridRow {
                GridCell(alignment: .center) {
                    Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                        GridRow {
                            GridCell {
                                Text("Geachte klant,")
                                    .style("font-size:22px; line-height:30px; font-weight:600; margin:0 0 6px 0;")
                                Text("Vanaf nu brengen wij u tweewekelijks per mail op de hoogte van de status van uw Peppol-facturen. Op die manier willen we u een helder overzicht bieden en eventuele misverstanden vermijden.")
                                    .style("font-size:16px; line-height:24px; margin:0;")
                            }
                            .style("font-family:Arial, Helvetica, sans-serif; color:#0f172a;")
                        }
                    }
                    .style("border-collapse:collapse; width:\(contentWidth - cardInnerMargin)px; max-width:\(contentWidth - cardInnerMargin)px;")
                }
                .style("background:#ABBBC7; padding:24px 12px 24px 12px;")
            }
            GridRow {
                GridCell(alignment: .center) {
                    Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                        GridRow {
                            GridCell(height: cardInnerMargin) {
                                RawHTML("&nbsp;")
                            }
                            .style("height:\(cardInnerMargin)px; line-height:22px; font-size:22px; background:#ffffff; border-top-left-radius:\(cardCornerRadius)px; border-top-right-radius:\(cardCornerRadius)px;")
                        }
                    }
                    .style("border-collapse:collapse; width:\(contentWidth)px; max-width:\(contentWidth)px;")
                }
                .style("background:#ABBBC7; padding:0 12px;")
            }
            GridRow {
                GridCell(alignment: .center) {
                    Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                        GridRow {
                            GridCell {
                                Text("In het overzicht hieronder vindt u al uw openstaande facturen die via Peppol werden verstuurd. Facturen van vóór de overstap naar Peppol die eind 2025 nog niet via Peppol verzonden werden, zijn niet in dit overzicht opgenomen.")
                                    .style("font-family:Arial, Helvetica, sans-serif; font-size:16px; line-height:24px; color:#111827;")
                                Spacer(height: 16)
                                Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                                    GridRow {
                                        GridCell(alignment: .center) {
                                            Grid(role: .presentation, cellpadding: 0, cellspacing: 0, border: 0) {
                                                GridRow {
                                                    GridCell {
                                                        Text(markdown: "⚠️ **Belangrijk:** deze e-mail is geen betalingsherinnering en geen aanmaning. Ze dient uitsluitend ter informatie.")
                                                            .style("font-family:Arial, Helvetica, sans-serif;font-size:14px;line-height:20px;color:#7c2d12;")
                                                    }
                                                    .style("padding:12px 12px;")
                                                }
                                            }
                                            .style("border:1px solid #fed7aa; border-radius:10px; background:#fff7ed;")
                                        }
                                    }
                                }
                                Spacer(height: 18)
                                
                                //Invoices Table hier
                                
                                Spacer(height: 18)
                                Text {
                                    "De details van deze facturen zijn steeds beschikbaar na login op onze website"
                                    Link("www.novem.com", destination: "www.novem.com")
                                        .style("color:#2563eb; text-decoration:underline;")
                                    Text(markdown: ", onder **Novem** > **Profiel**.")
                                }
                                .style("font-family:Arial, Helvetica, sans-serif; font-size:14px; line-height:20px; color:#374151;")
                                Spacer(height: 18)
                                Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                                    GridRow {
                                        GridCell(alignment: .leading) {
                                            Grid(role: .presentation, cellpadding: 0, cellspacing: 0, border: 0) {
                                                GridRow {
                                                    GridCell(alignment: .center, attributes: ["bgcolor": "#2563eb"]) {
                                                        ButtonLink("Facturen", destination: "www.novem.com/invoices")
                                                            .style("display:inline-block; padding:12px 18px; font-family:Arial, Helvetica, sans-serif; font-size:14px; line-height:18px; color:#ffffff; text-decoration:none; font-weight:700;")
                                                    }
                                                    .style("border-radius:8px;")
                                                }
                                            }
                                            .style("border-collapse:collapse;")
                                        }
                                    }
                                }
                                .style("border-collapse:collapse;")
                                Spacer(height: 20)
                                Text {
                                    "Contacteer ons via"
                                    Link("no-reply@novem.info", destination: "mailto:no-reply@novem.info")
                                        .style("color:#2563eb; text-decoration:underline;")
                                    Text(markdown: " of door te bellen. \n\n Met vriendelijke groet \n Novem")
                                }
                                .style("font-family:Arial, Helvetica, sans-serif; font-size:16px; line-height:24px; color:#111827;")
                                
                                GridRow {
                                    GridCell {
                                        Text("Dit is een automatische e-mail. U kan niet antwoorden op dit bericht.")
                                            .style("font-family:Arial, Helvetica, sans-serif; font-size:12px; line-height:18px; color:#6b7280;")
                                    }
                                    .style("padding:16px 24px; background:#f3f4f6;")
                                }
                            }
                            .style("padding:0px 20px 20px 20px;")
                        }
                    }
                    .style("border-collapse:collapse; width:\(contentWidth)px; max-width:\(contentWidth)px; background:#ffffff; border-bottom-left-radius:\(cardCornerRadius)px; border-bottom-right-radius:\(cardCornerRadius)px; overflow:hidden;")
                }
                .style("background:#D1DAE0; padding:0 12px 28px 12px;")
            }
        }
        .style("border-collapse:collapse; width:100%; background:#D1DAE0;")
    } head: {
        Meta(.charset("utf-8"))
        Meta(.name("viewport", content: "width=device-width,initial-scale=1"))
        Meta(.name("x-apple-disable-message-reformatting"))
        Meta(.name("color-scheme", content: "light"))
        Meta(.name("supported-color-schemes", content: "light"))
        Title("Peppol-facturen")
    }
    .language("en")
    .style("margin:0; padding:0; background:#D1DAE0;")
    
    print("")
    print(doc.render())
    print("")
    
    let client = Client(
        host: "smtp.office365.com",
        port: 587,
        heloName: "",
        authentication: .login(username: "", password: "")
    )
    
    let mail = Mail(from: "", to: "", subject: "Test htmlbuilder") {
        doc.render()
    }
    
    do {
        try await client.send(mail)
        #expect(Bool(true))
    } catch {
        #expect(Bool(false))
    }
}
