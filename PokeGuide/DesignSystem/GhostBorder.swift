//
//  GhostBorder.swift
//  PokeGuide
//
//  Subtle outline_variant border — felt, not seen.
//

import SwiftUI

struct GhostBorder: ViewModifier {
    var cornerRadius: CGFloat = KARadius.lg
    var opacity: Double = 0.10

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.outlineVariant.opacity(opacity), lineWidth: 1)
        )
    }
}

extension View {
    func ghostBorder(cornerRadius: CGFloat = KARadius.lg, opacity: Double = 0.10) -> some View {
        modifier(GhostBorder(cornerRadius: cornerRadius, opacity: opacity))
    }
}
