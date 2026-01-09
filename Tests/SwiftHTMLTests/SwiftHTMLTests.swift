//
//  SwiftHTMLTests.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

import Testing
import Foundation
@testable import SwiftHTML

@Test
func renderHTML1() {
    let doc = HTMLDocument {
        Grid {
            GridRow {
                GridCell {
                    Grid {
                        GridRow {
                            GridCell {
                                Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
                                    GridRow {
                                        GridCell(alignment: .leading, valign: "middle") {
                                            Image(src: "https://funico.international/_BE/images/layout/Logo_Funico_wit.png", alt: "Funico", width: 120)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            GridRow {
                Text("Hello, World!")
            }
        }
        
        Text(markdown: "# This **is** a heading\n\nThis is a paragraph.")
    }
    .language("en")
    
    print("")
    print(doc.render())
    print("")
    
    let rendered: String =
    """
    <!doctype html>
    <html lang="en">
      <table border="0" cellpadding="0" cellspacing="0" role="presentation" width="100%">
        <tr>
          <td align="center" style="background:#2C5573;">
            <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse;">
              <tr>
                <td align="center" style="padding:14px 12px;">
                  <table role="presentation" width="333" cellpadding="0" cellspacing="0" border="0"
                                      style="border-collapse:collapse; width:333px; max-width:333px;">
                    <tr>
                      <td align="left" valign="middle">
                        <img
                        src="https://funico.international/_BE/images/layout/Logo_Funico_wit.png"
                        alt="Funico"
                        width="120"
                        style="display:block; border:0; outline:none; text-decoration:none; height:auto;"
                        />
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <div>
            Hello, World!
          </div>
        </tr>
      </table>
      <div>
        # This <strong>is</strong> a heading<br><br>This is a paragraph.
      </div>
    </html>
    """
    
    #expect(rendered == doc.render())
}
