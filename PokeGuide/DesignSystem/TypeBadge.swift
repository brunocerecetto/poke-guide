//
//  TypeBadge.swift
//  PokeGuide
//
//  Pill-shaped badge — 10% opacity background + saturated text.
//

import SwiftUI

struct TypeBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(KATypography.labelSm)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, KASpacing.xs)
            .background(color.opacity(0.10))
            .clipShape(Capsule())
    }
}
