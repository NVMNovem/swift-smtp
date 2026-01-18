//
//  RenderMode.swift
//  swift-smtp
//
//  Created by Damian Van de Kauter on 16/01/2026.
//

public enum RenderMode {
    
    /// Choose inline/block rendering based on the element tag.
    case automatic
    /// Render without pretty-printing newlines/indentation between children.
    case inline
    /// Render with pretty-printing newlines/indentation between children.
    case block
}
