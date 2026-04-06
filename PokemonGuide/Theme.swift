//
//  Theme.swift
//  pokemon guide
//
//  Paleta de colores + componentes reutilizables. Soporta FireRed y LeafGreen, light y dark mode.
//

import SwiftUI

// MARK: - FireRed Color Palette (Adaptive: Light + Dark)

extension Color {
    // FireRed accent colors (same in both modes)
    static let fireRed = Color(red: 0.88, green: 0.18, blue: 0.12)
    static let fireOrange = Color(red: 0.93, green: 0.50, blue: 0.10)
    static let fireYellow = Color(red: 0.98, green: 0.78, blue: 0.15)
    static let fireBlue = Color(red: 0.22, green: 0.48, blue: 0.85)
    static let fireGreen = Color(red: 0.20, green: 0.72, blue: 0.35)

    // LeafGreen accent colors (same in both modes)
    static let leafGreen = Color(red: 0.18, green: 0.65, blue: 0.32)
    static let leafTeal = Color(red: 0.15, green: 0.55, blue: 0.52)
    static let leafYellow = Color(red: 0.70, green: 0.82, blue: 0.20)

    // Surfaces (adaptive)
    static let fireBg = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)
            : UIColor(red: 0.96, green: 0.95, blue: 0.93, alpha: 1)
    })

    static let fireCard = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.16, blue: 0.18, alpha: 1)
            : UIColor.white
    })

    static let fireCardAlt = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1)
            : UIColor(red: 0.98, green: 0.97, blue: 0.96, alpha: 1)
    })

    // Text (adaptive)
    static let fireTextPrimary = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1)
            : UIColor(red: 0.13, green: 0.13, blue: 0.15, alpha: 1)
    })

    static let fireTextSecondary = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.60, green: 0.60, blue: 0.65, alpha: 1)
            : UIColor(red: 0.45, green: 0.44, blue: 0.48, alpha: 1)
    })

    // Legacy aliases (adaptive)
    static let fireDark = fireBg

    static let fireGray = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1)
            : UIColor(red: 0.93, green: 0.92, blue: 0.90, alpha: 1)
    })

    static let fireLightGray = fireTextSecondary
}

// MARK: - GameVersion + Color (SwiftUI layer)

extension GameVersion {
    var accentColor: Color {
        switch self {
        case .fireRed:   return .fireRed
        case .leafGreen: return .leafGreen
        }
    }

    var secondaryColor: Color {
        switch self {
        case .fireRed:   return .fireOrange
        case .leafGreen: return .leafTeal
        }
    }
}

extension Starter {
    var type: PokemonType {
        switch self {
        case .bulbasaur:  return .grass
        case .charmander: return .fire
        case .squirtle:   return .water
        }
    }
}

// MARK: - Dynamic Theme Colors (per GameVersion)

struct ThemeColors {
    let accent: Color
    let secondary: Color
    let icon: String
    let gradientColors: [Color]

    static let fireRed = ThemeColors(
        accent: .fireRed,
        secondary: .fireOrange,
        icon: "flame.fill",
        gradientColors: [.fireRed, .fireOrange, .fireYellow, .fireOrange, .fireRed]
    )

    static let leafGreen = ThemeColors(
        accent: .leafGreen,
        secondary: .leafTeal,
        icon: "leaf.fill",
        gradientColors: [.leafGreen, .leafTeal, .leafYellow, .leafTeal, .leafGreen]
    )

    static func forVersion(_ version: GameVersion) -> ThemeColors {
        switch version {
        case .fireRed:   return .fireRed
        case .leafGreen: return .leafGreen
        }
    }
}

// MARK: - Theme Environment Key

private struct ThemeColorsKey: EnvironmentKey {
    static let defaultValue = ThemeColors.fireRed
}

extension EnvironmentValues {
    var themeColors: ThemeColors {
        get { self[ThemeColorsKey.self] }
        set { self[ThemeColorsKey.self] = newValue }
    }
}

// MARK: - Soft Card Modifier

struct SoftCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var tint: Color = .clear
    var shadowOpacity: Double = 0.08
    var shadowRadius: CGFloat = 10

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let isDark = colorScheme == .dark
        let effectiveShadowOpacity = isDark ? shadowOpacity * 0.4 : shadowOpacity
        let borderOpacity: Double = isDark ? 0.12 : 0.04

        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.fireCard)
                    .shadow(color: tint != .clear ? tint.opacity(isDark ? 0.06 : 0.10) : .black.opacity(effectiveShadowOpacity), radius: shadowRadius, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: 0.5)
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
            .foregroundColor(isCompleted ? .fireGreen : .fireTextSecondary.opacity(0.4))
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
    @Environment(\.themeColors) private var theme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(theme.accent)
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(theme.accent)
        }
        .textCase(nil)
    }
}

// MARK: - Pokéball Progress Ring

struct PokeballProgress: View {
    let progress: Double
    @Environment(\.themeColors) private var theme
    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.fireTextSecondary.opacity(0.15), lineWidth: 10)
                .frame(width: 130, height: 130)

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: theme.gradientColors,
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 130, height: 130)
                .rotationEffect(.degrees(-90))
                .shadow(color: theme.accent.opacity(0.2), radius: 6)

            // Center
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.accent)
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

// MARK: - Guide Disclaimer Banner

struct GuideDisclaimerBanner: View {
    @EnvironmentObject var gameConfig: GameConfig
    @Environment(\.themeColors) private var theme

    var isMatchingGuide: Bool {
        gameConfig.version == .fireRed && gameConfig.starter == .squirtle
    }

    var body: some View {
        if !isMatchingGuide {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.accent)

                Text("Esta guía está optimizada para **Fire Red + Squirtle**. Los pasos son similares pero pueden variar exclusivos y evoluciones.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.accent.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.accent.opacity(0.15), lineWidth: 1)
                    )
            )
            .padding(.horizontal)
        }
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
        let colors: [Color] = theme.gradientColors + [.fireGreen, .fireBlue]
        particles = (0..<25).map { i in
            (id: i, x: CGFloat.random(in: -120...120), y: CGFloat.random(in: -160 ... -30),
             color: colors.randomElement()!, rotation: Double.random(in: 180...720))
        }
        isAnimating = false
        withAnimation(.easeOut(duration: 1.2)) { isAnimating = true }
    }
}
