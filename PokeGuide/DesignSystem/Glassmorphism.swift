//
//  Glassmorphism.swift
//  PokeGuide
//
//  Frosted glass effect with optional type color bleed.
//

import SwiftUI

struct Glassmorphism: ViewModifier {
    var typeColor: Color?
    var cornerRadius: CGFloat = KARadius.lg

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(typeColor?.opacity(0.15) ?? Color.clear)
                    )
            )
    }
}

extension View {
    func glassmorphism(typeColor: Color? = nil, cornerRadius: CGFloat = KARadius.lg) -> some View {
        modifier(Glassmorphism(typeColor: typeColor, cornerRadius: cornerRadius))
    }
}
