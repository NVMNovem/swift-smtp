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

struct TestData {
    
    let column1: String
    let column2: Double
    let column3: Date
    let column4: Date
    
    static let examples: [TestData] = [
        .init(column1: "F-12345", column2: 199.99, column3: Date().addingTimeInterval(60 * 60 * 24 * 7), column4: Date()),
        .init(column1: "F-67890", column2: 24.99, column3: Date().addingTimeInterval(60 * 60 * 24 * 3), column4: Date()),
        .init(column1: "F-54321", column2: 349.50, column3: Date().addingTimeInterval(60 * 60 * 24 * 14), column4: Date())
    ]
}

@Test
func renderHTML1() async throws {
    let doc = HTMLDocument {
        Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
            GridRowCell(alignment: .center) {
                Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                    GridRowCell {
                        Text("Geachte klant,")
                            .style(.fontSize("22px"), .lineHeight("30px"), .fontWeight("600"), .margin("0 0 6px 0"))
                        Text("Vanaf nu brengen wij u tweewekelijks per mail op de hoogte van de status van uw Peppol-facturen. Op die manier willen we u een helder overzicht bieden en eventuele misverstanden vermijden.")
                            .style(.fontSize("16px"), .lineHeight("24px"), .margin("0"))
                    }
                    .style(.fontFamily("Arial, Helvetica, sans-serif"), .color("#0f172a"))
                }
                .style(.borderCollapse("collapse"), .width("550px"), .maxWidth("550px"))
            }
            GridRowCell(alignment: .center) {
                Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                    GridRowCell {
                        Text("Hello world")
                            .style(.fontFamily("Arial, Helvetica, sans-serif"), .fontSize("16px"), .lineHeight("24px"), .color("#111827"))
                        Spacer(height: 16)
                        Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                            GridRowCell(alignment: .center) {
                                Grid(role: .presentation, cellpadding: 0, cellspacing: 0, border: 0) {
                                    GridRowCell {
                                        Text(markdown: "⚠️ **Important:** Hello world")
                                            .style(.fontFamily("Arial, Helvetica, sans-serif"), .fontSize("14px"), .lineHeight("20px"), .color("#7c2d12"))
                                    }
                                    .style(.padding("12px 12px"))
                                }
                                .style(.border("1px solid #fcd9b6"), .borderRadius("10px"), .background("#fffbf7"))
                            }
                        }
                        Spacer(height: 18)
                        
                        Table(
                            TestData.examples,
                            headerCellStyle: .padding("10px"), .background("#f3f4f6"), .borderBottom("1px solid #e5e7eb"), .fontSize("12px"), .fontWeight("bold"), .fontFamily("Arial, Helvetica, sans-serif"), .lineHeight("16px"), .color("#111827"),
                            cellStyle: .padding("10px 12px"), .borderBottom("1px solid #e5e7eb"), .fontFamily("Arial, Helvetica, sans-serif"), .fontSize("13px"), .lineHeight("18px"), .color("#111827")
                        ) {
                            Column("Column 1", alignment: .leading)
                            Column("Column 2", alignment: .leading)
                            Column("Column 3", alignment: .leading)
                            Column("Column 4", alignment: .trailing)
                        } row: { testData in
                            Text(testData.column1)
                            Text(testData.column2.formatted(.currency(code: "EUR")))
                            Text(testData.column3.formatted(date: .numeric, time: .omitted))
                            Text(testData.column4.formatted(date: .numeric, time: .omitted))
                        }
                        .style(.border("1px solid #D1DAE0"), .borderRadius("10px"), .overflow("hidden"))
                        Spacer(height: 20)
                        Inline {
                            Text("Hello world")
                            Link("info@example.com", destination: "mailto:info@example.com")
                                .style(.color("#2563eb"), .textDecoration("underline"))
                        }
                        .style(.fontFamily("Arial, Helvetica, sans-serif"), .fontSize("16px"), .lineHeight("24px"), .color("#111827"))
                        
                        GridRowCell {
                            Text("This is an automatic e-mail.")
                                .style(.fontFamily("Arial, Helvetica, sans-serif"), .fontSize("12px"), .lineHeight("18px"), .color("#6b7280"))
                        }
                        .style(.padding("16px 24px"), .background("#f3f4f6"))
                    }
                    .style(.padding("0px 20px 20px 20px;"))
                }
                .style(.borderCollapse("collapse"), .width("600px"), .maxWidth("600px"), .background("#ffffff"), .borderRadius("15px"), .overflow("hidden"))
            }
            .style(.background("#D1DAE0"), .padding("0 12px 50px 12px"))
        }
        .style(.borderCollapse("collapse"), .width("100%"), .background("#D1DAE0"))
    } head: {
        Meta(.charset("utf-8"))
        Meta(.name("viewport", content: "width=device-width,initial-scale=1"))
        Meta(.name("x-apple-disable-message-reformatting"))
        Meta(.name("color-scheme", content: "light"))
        Meta(.name("supported-color-schemes", content: "light"))
        Title("Text-mail")
    }
    .language("en")
    .style(.margin("0"), .padding("0"), .background("#169F84"))
    
    #expect(Bool(true))
}
