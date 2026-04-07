//
//  AmbientShadow.swift
//  PokeGuide
//
//  Highly diffused ambient shadow for floating elements.
//

import SwiftUI

struct AmbientShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: Color.onSurface.opacity(0.06), radius: 40, y: 0)
    }
}

extension View {
    func ambientShadow() -> some View {
        modifier(AmbientShadow())
    }
}
