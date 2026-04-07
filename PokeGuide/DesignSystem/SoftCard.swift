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
                    .fill(Color.surfaceContainerLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.outlineVariant.opacity(0.10), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func softCard(
        cornerRadius: CGFloat = KARadius.lg,
        tint: Color = .clear,
        shadowOpacity: Double = 0,
        shadowRadius: CGFloat = 0
    ) -> some View {
        modifier(SoftCard(cornerRadius: cornerRadius, tint: tint))
    }
}
