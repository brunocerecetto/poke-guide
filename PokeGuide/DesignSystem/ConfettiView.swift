//
//  ConfettiView.swift
//  PokeGuide
//
//  Celebration particle burst effect.
//

import SwiftUI

struct ConfettiView: View {
    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, color: Color, rotation: Double)] = []
    @State private var isAnimating = false
    @Environment(\.themeColors) private var theme
    let trigger: Bool

    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { p in
                Circle()
                    .fill(p.color)
                    .frame(width: 6, height: 6)
                    .shadow(color: p.color.opacity(0.4), radius: 2)
                    .offset(x: isAnimating ? p.x : 0, y: isAnimating ? p.y : 0)
                    .opacity(isAnimating ? 0 : 1)
                    .rotationEffect(.degrees(isAnimating ? p.rotation : 0))
            }
        }
        .task(id: trigger) {
            guard trigger else { return }
            spawnParticles()
            try? await Task.sleep(for: .seconds(1.4))
            particles = []
            isAnimating = false
        }
    }

    private func spawnParticles() {
        let colors: [Color] = theme.gradientColors + [.success, .kaSecondaryContainer]
        particles = (0..<25).map { i in
            (id: i, x: CGFloat.random(in: -120...120), y: CGFloat.random(in: -160 ... -30),
             color: colors.randomElement() ?? theme.secondary, rotation: Double.random(in: 180...720))
        }
        isAnimating = false
        withAnimation(.easeOut(duration: 1.2)) { isAnimating = true }
    }
}
