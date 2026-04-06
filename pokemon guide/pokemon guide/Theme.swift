//
//  Theme.swift
//  pokemon guide
//
//  Paleta FireRed Light Mode + componentes reutilizables
//

import SwiftUI

// MARK: - FireRed Color Palette (Light Mode)

extension Color {
    // Accent colors
    static let fireRed = Color(red: 0.88, green: 0.18, blue: 0.12)
    static let fireOrange = Color(red: 0.93, green: 0.50, blue: 0.10)
    static let fireYellow = Color(red: 0.98, green: 0.78, blue: 0.15)
    static let fireBlue = Color(red: 0.22, green: 0.48, blue: 0.85)
    static let fireGreen = Color(red: 0.20, green: 0.72, blue: 0.35)

    // Surfaces
    static let fireBg = Color(red: 0.96, green: 0.95, blue: 0.93)       // warm cream bg
    static let fireCard = Color.white
    static let fireCardAlt = Color(red: 0.98, green: 0.97, blue: 0.96)  // slightly warm white

    // Text
    static let fireTextPrimary = Color(red: 0.13, green: 0.13, blue: 0.15)
    static let fireTextSecondary = Color(red: 0.45, green: 0.44, blue: 0.48)

    // Legacy aliases (used by sub-views)
    static let fireDark = fireBg
    static let fireGray = Color(red: 0.93, green: 0.92, blue: 0.90)
    static let fireLightGray = fireTextSecondary
}

// MARK: - Soft Card Modifier

struct SoftCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var tint: Color = .clear
    var shadowOpacity: Double = 0.08
    var shadowRadius: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.fireCard)
                    .shadow(color: tint != .clear ? tint.opacity(0.10) : .black.opacity(shadowOpacity), radius: shadowRadius, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.black.opacity(0.04), lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func softCard(
        cornerRadius: CGFloat = 20,
        tint: Color = .clear,
        shadowOpacity: Double = 0.08,
        shadowRadius: CGFloat = 10
    ) -> some View {
        modifier(SoftCard(
            cornerRadius: cornerRadius,
            tint: tint,
            shadowOpacity: shadowOpacity,
            shadowRadius: shadowRadius
        ))
    }

    // Keep liquidGlass as alias for softCard so existing views don't break
    func liquidGlass(
        cornerRadius: CGFloat = 20,
        tint: Color = .white,
        tintOpacity: Double = 0.06,
        borderOpacity: Double = 0.25,
        shadowRadius: CGFloat = 10,
        intensity: Double = 1.0
    ) -> some View {
        modifier(SoftCard(
            cornerRadius: cornerRadius,
            tint: tint,
            shadowOpacity: 0.08 * intensity,
            shadowRadius: shadowRadius
        ))
    }
}

// MARK: - Glow Text (lighter for light mode)

struct GlowText: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.25), radius: radius * 0.5)
    }
}

extension View {
    func glowText(color: Color = .fireOrange, radius: CGFloat = 6) -> some View {
        modifier(GlowText(color: color, radius: radius))
    }
}

// MARK: - Animated Checkmark

struct AnimatedCheck: View {
    let isCompleted: Bool
    var size: CGFloat = 24

    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.system(size: size))
            .foregroundColor(isCompleted ? .fireGreen : Color.black.opacity(0.2))
            .scaleEffect(scale)
            .onChange(of: isCompleted) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { scale = 1.3 }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.15)) { scale = 1.0 }
                }
            }
    }
}

// MARK: - Section Header

struct FireRedSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.fireRed)
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.fireRed)
        }
        .textCase(nil)
    }
}

// MARK: - Pokéball Progress Ring

struct PokeballProgress: View {
    let progress: Double
    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.black.opacity(0.06), lineWidth: 10)
                .frame(width: 130, height: 130)

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [.fireRed, .fireOrange, .fireYellow, .fireOrange, .fireRed],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 130, height: 130)
                .rotationEffect(.degrees(-90))
                .shadow(color: .fireRed.opacity(0.2), radius: 6)

            // Center
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.fireRed)
                Text("completado")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.5)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { animatedProgress = progress }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) { animatedProgress = newValue }
        }
    }
}

// MARK: - Type Badge

struct TypeBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.gradient)
            .clipShape(Capsule())
    }
}

// MARK: - FireRed Card

struct FireRedCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding()
            .softCard(cornerRadius: 16)
    }
}

// MARK: - Shake Effect

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 6
    var shakesPerUnit = 3
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, color: Color, rotation: Double)] = []
    @State private var isAnimating = false
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
        .onChange(of: trigger) { _, newValue in
            if newValue { spawnParticles() }
        }
    }

    private func spawnParticles() {
        let colors: [Color] = [.fireRed, .fireOrange, .fireYellow, .fireGreen, .fireBlue]
        particles = (0..<25).map { i in
            (id: i, x: CGFloat.random(in: -120...120), y: CGFloat.random(in: -160 ... -30),
             color: colors.randomElement()!, rotation: Double.random(in: 180...720))
        }
        isAnimating = false
        withAnimation(.easeOut(duration: 1.2)) { isAnimating = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { particles = []; isAnimating = false }
    }
}
