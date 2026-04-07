//
//  AnimatedCheck.swift
//  PokeGuide
//
//  Animated checkmark toggle with spring animation.
//

import SwiftUI

struct AnimatedCheck: View {
    let isCompleted: Bool
    var size: CGFloat = 24

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.system(size: size))
            .foregroundColor(isCompleted ? .success : .onSurfaceVariant.opacity(0.4))
            .scaleEffect(scale)
            .onChange(of: isCompleted) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { scale = 1.3 }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.15)) { scale = 1.0 }
                }
            }
    }
}
