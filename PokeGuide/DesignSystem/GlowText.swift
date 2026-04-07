//
//  GlowText.swift
//  PokeGuide
//
//  Subtle glow shadow behind text.
//

import SwiftUI

struct GlowText: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.25), radius: radius * 0.5)
    }
}

extension View {
    func glowText(color: Color = .primaryContainer, radius: CGFloat = 6) -> some View {
        modifier(GlowText(color: color, radius: radius))
    }
}
