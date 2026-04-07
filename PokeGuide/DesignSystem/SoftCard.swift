//
//  SoftCard.swift
//  PokeGuide
//
//  Tonal card modifier — no drop shadows, ghost border.
//

import SwiftUI

struct SoftCard: ViewModifier {
    var cornerRadius: CGFloat = KARadius.lg
    var tint: Color = .clear
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.outlineVariant.opacity(0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func softCard(
        cornerRadius: CGFloat = KARadius.lg,
        tint: Color = .clear
    ) -> some View {
        modifier(SoftCard(cornerRadius: cornerRadius, tint: tint))
    }
}
