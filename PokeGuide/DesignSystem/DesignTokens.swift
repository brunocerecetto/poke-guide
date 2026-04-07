//
//  DesignTokens.swift
//  PokeGuide
//
//  "The Kinetic Archive" — color, typography, spacing, radius, and gradient tokens.
//

import SwiftUI

// MARK: - Color Tokens (Light-mode)

extension Color {
    // Surfaces (Nested Depth)
    static let surface = Color(hex: "#f9f9f9")
    static let surfaceContainerLow = Color(hex: "#f3f3f3")
    static let surfaceContainerHigh = Color(hex: "#e6e6e6")
    static let surfaceContainerHighest = Color(hex: "#e2e2e2")
    static let surfaceBright = Color(hex: "#f5f5f5")

    // Text & Icons
    static let onSurface = Color(hex: "#1a1c1c")
    static let onSurfaceVariant = Color(hex: "#3f4948")
    static let outlineVariant = Color(hex: "#bfc9c8")

    // Primary (Energy)
    static let kaPrimary = Color(hex: "#bc0100")
    static let primaryContainer = Color(hex: "#eb0000")
    static let onPrimary = Color.white

    // Secondary
    static let kaSecondaryContainer = Color(hex: "#0356ff")

    // Semantic
    static let success = Color(red: 0.20, green: 0.72, blue: 0.35)
    static let inverseSurface = Color(hex: "#2f3131")
    static let kaYellow = Color(red: 0.98, green: 0.78, blue: 0.15)

    // MARK: Deprecated Aliases

    @available(*, deprecated, renamed: "kaPrimary")
    static let fireRed = kaPrimary
    @available(*, deprecated, renamed: "primaryContainer")
    static let fireOrange = Color(red: 0.93, green: 0.50, blue: 0.10)
    @available(*, deprecated, renamed: "kaYellow")
    static let fireYellow = kaYellow
    @available(*, deprecated, renamed: "kaSecondaryContainer")
    static let fireBlue = Color(red: 0.22, green: 0.48, blue: 0.85)
    @available(*, deprecated, renamed: "success")
    static let fireGreen = success

    @available(*, deprecated, renamed: "success")
    static let leafGreen = Color(red: 0.18, green: 0.65, blue: 0.32)
    @available(*, deprecated, renamed: "onSurfaceVariant")
    static let leafTeal = Color(red: 0.15, green: 0.55, blue: 0.52)
    @available(*, deprecated, renamed: "kaYellow")
    static let leafYellow = Color(red: 0.70, green: 0.82, blue: 0.20)

    @available(*, deprecated, renamed: "surface")
    static let fireBg = surface
    @available(*, deprecated, renamed: "surfaceContainerLow")
    static let fireCard = surfaceContainerLow
    @available(*, deprecated, renamed: "surfaceContainerHigh")
    static let fireCardAlt = surfaceContainerHigh
    @available(*, deprecated, renamed: "onSurface")
    static let fireTextPrimary = onSurface
    @available(*, deprecated, renamed: "onSurfaceVariant")
    static let fireTextSecondary = onSurfaceVariant
    @available(*, deprecated, renamed: "surface")
    static let fireDark = surface
    @available(*, deprecated, renamed: "surfaceContainerHighest")
    static let fireGray = surfaceContainerHighest
    @available(*, deprecated, renamed: "onSurfaceVariant")
    static let fireLightGray = onSurfaceVariant
}

// MARK: - Typography Scale

enum KATypography {
    static let displayLg: Font = .system(size: 56, weight: .heavy, design: .rounded)
    static let headlineLg: Font = .system(size: 24, weight: .bold, design: .rounded)
    static let headlineMd: Font = .system(size: 20, weight: .bold, design: .rounded)
    static let titleMd: Font = .system(size: 16, weight: .semibold, design: .rounded)
    static let titleSm: Font = .system(size: 14, weight: .semibold, design: .rounded)
    static let bodyMd: Font = .system(size: 15, weight: .regular, design: .default)
    static let bodySmall: Font = .system(size: 13, weight: .medium, design: .default)
    static let labelSm: Font = .system(size: 11, weight: .bold, design: .rounded)
    static let labelXs: Font = .system(size: 9, weight: .heavy, design: .rounded)
}

// MARK: - Spacing Scale

enum KASpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius Scale

enum KARadius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 32
    static let xl: CGFloat = 48
}

// MARK: - Animation Tokens

enum KAAnimation {
    /// Standard spring for element appearance (cards, list items).
    static let appearSpring = Animation.spring(response: 0.5, dampingFraction: 0.8)
    /// Faster spring for interactive feedback (toggles, checks).
    static let interactiveSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    /// Celebration/confetti duration.
    static let celebrationDuration: Double = 1.4
    /// Stagger delay between list items.
    static let staggerDelay: Double = 0.04
}

// MARK: - Energy Gradient

extension LinearGradient {
    static let energyGradient = LinearGradient(
        colors: [.kaPrimary, .primaryContainer],
        startPoint: UnitPoint(x: 0, y: 1),
        endPoint: UnitPoint(x: 1, y: 0)
    )
}

// MARK: - Tight Tracking

struct TightTracking: ViewModifier {
    let factor: CGFloat
    func body(content: Content) -> some View {
        content.tracking(factor)
    }
}

extension View {
    func tightTracking(_ size: CGFloat = 24) -> some View {
        modifier(TightTracking(factor: -0.02 * size))
    }
}
