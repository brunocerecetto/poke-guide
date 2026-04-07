//
//  Theme.swift
//  poke guide
//
//  Dynamic theme colors (per game), GameVersion/Starter extensions, and Color hex init.
//  Design tokens and components live in DesignSystem/.
//

import SwiftUI

// MARK: - Color from Hex String

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)

        if cleaned.count == 8 {
            self.init(
                red: Double((rgb >> 24) & 0xFF) / 255.0,
                green: Double((rgb >> 16) & 0xFF) / 255.0,
                blue: Double((rgb >> 8) & 0xFF) / 255.0,
                opacity: Double(rgb & 0xFF) / 255.0
            )
        } else {
            self.init(
                red: Double((rgb >> 16) & 0xFF) / 255.0,
                green: Double((rgb >> 8) & 0xFF) / 255.0,
                blue: Double(rgb & 0xFF) / 255.0
            )
        }
    }
}

// MARK: - GameVersion + Color

extension GameVersion {
    var accentColor: Color {
        switch self {
        case .fireRed:   return .kaPrimary
        case .leafGreen: return .success
        }
    }

    var secondaryColor: Color {
        switch self {
        case .fireRed:   return .primaryContainer
        case .leafGreen: return Color(red: 0.15, green: 0.55, blue: 0.52)
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

// MARK: - Dynamic Theme Colors (per Game)

struct ThemeColors {
    let accent: Color
    let secondary: Color
    let icon: String
    let gradientColors: [Color]

    static let fireRed = ThemeColors(
        accent: .kaPrimary,
        secondary: .primaryContainer,
        icon: "flame.fill",
        gradientColors: [.kaPrimary, .primaryContainer]
    )

    static let leafGreen = ThemeColors(
        accent: Color(red: 0.18, green: 0.65, blue: 0.32),
        secondary: Color(red: 0.15, green: 0.55, blue: 0.52),
        icon: "leaf.fill",
        gradientColors: [Color(red: 0.18, green: 0.65, blue: 0.32), Color(red: 0.15, green: 0.55, blue: 0.52)]
    )

    static func forVersion(_ version: GameVersion) -> ThemeColors {
        switch version {
        case .fireRed:   return .fireRed
        case .leafGreen: return .leafGreen
        }
    }

    static func fromHex(accent: String, secondary: String, icon: String) -> ThemeColors {
        let accentColor = Color(hex: accent)
        let secondaryColor = Color(hex: secondary)
        return ThemeColors(
            accent: accentColor,
            secondary: secondaryColor,
            icon: icon,
            gradientColors: [accentColor, secondaryColor]
        )
    }

    static func forConfig(_ config: GameConfig) -> ThemeColors {
        if let legacy = config.legacyVersion {
            return forVersion(legacy)
        }
        return fromHex(
            accent: config.accentColorHex,
            secondary: config.secondaryColorHex,
            icon: config.iconName
        )
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
