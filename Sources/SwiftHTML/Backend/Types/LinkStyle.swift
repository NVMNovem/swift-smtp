//
//  LinkStyle.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public enum LinkStyle {
    
    case plain
    case button(ButtonStyle)

    public static var button: LinkStyle {
        .button(.default)
    }
}
