//
//  GameConfig.swift
//  PokemonGuide
//
//  Selección de versión del juego y starter, persistida en UserDefaults.
//
//  Supports string-based game IDs for 38+ Pokémon games.
//  Legacy enums (GameVersion, Starter) are preserved for backward compatibility
//  with existing views that haven't been migrated yet.
//

import Foundation
import Combine

// MARK: - Legacy Enums (kept for backward compat with existing views)

enum GameVersion: String, CaseIterable, Codable {
    case fireRed
    case leafGreen

    var displayName: String {
        switch self {
        case .fireRed:   return "POKÉMON FIRERED"
        case .leafGreen: return "POKÉMON LEAFGREEN"
        }
    }

    var shortName: String {
        switch self {
        case .fireRed:   return "Fire Red"
        case .leafGreen: return "Leaf Green"
        }
    }

    var icon: String {
        switch self {
        case .fireRed:   return "flame.fill"
        case .leafGreen: return "leaf.fill"
        }
    }

    /// Map legacy enum to new string-based game ID
    var gameId: String {
        rawValue
    }

    /// Map legacy enum to hex accent color
    var accentColorHex: String {
        switch self {
        case .fireRed:   return "#E02D1F"
        case .leafGreen: return "#2EA652"
        }
    }

    /// Map legacy enum to hex secondary color
    var secondaryColorHex: String {
        switch self {
        case .fireRed:   return "#ED801A"
        case .leafGreen: return "#268D85"
        }
    }
}

enum Starter: String, CaseIterable, Codable {
    case bulbasaur
    case charmander
    case squirtle

    var displayName: String {
        switch self {
        case .bulbasaur:  return "Bulbasaur"
        case .charmander: return "Charmander"
        case .squirtle:   return "Squirtle"
        }
    }

    var emoji: String {
        switch self {
        case .bulbasaur:  return "🌿"
        case .charmander: return "🔥"
        case .squirtle:   return "🐢"
        }
    }

    var dexNumber: Int {
        switch self {
        case .bulbasaur:  return 1
        case .charmander: return 4
        case .squirtle:   return 7
        }
    }

    var pokemonTypeName: String {
        switch self {
        case .bulbasaur:  return "grass"
        case .charmander: return "fire"
        case .squirtle:   return "water"
        }
    }

    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(dexNumber).png")
    }
}

// MARK: - Game Config (data-driven)

class GameConfig: ObservableObject {
    private let defaults = UserDefaults.standard

    // Legacy keys (kept for migration)
    private static let legacyVersionKey = "gameVersion"
    private static let legacyStarterKey = "selectedStarter"

    // New keys
    private static let gameIdKey = "gameConfig.gameId"
    private static let starterDexKey = "gameConfig.starterDex"
    private static let gameNameKey = "gameConfig.gameName"
    private static let accentColorHexKey = "gameConfig.accentColorHex"
    private static let secondaryColorHexKey = "gameConfig.secondaryColorHex"
    private static let iconNameKey = "gameConfig.iconName"
    private static let configuredKey = "gameConfig.isConfigured"

    @Published var gameId: String {
        didSet { defaults.set(gameId, forKey: Self.gameIdKey) }
    }

    @Published var starterDex: Int {
        didSet { defaults.set(starterDex, forKey: Self.starterDexKey) }
    }

    @Published var gameName: String {
        didSet { defaults.set(gameName, forKey: Self.gameNameKey) }
    }

    @Published var accentColorHex: String {
        didSet { defaults.set(accentColorHex, forKey: Self.accentColorHexKey) }
    }

    @Published var secondaryColorHex: String {
        didSet { defaults.set(secondaryColorHex, forKey: Self.secondaryColorHexKey) }
    }

    @Published var iconName: String {
        didSet { defaults.set(iconName, forKey: Self.iconNameKey) }
    }

    var isConfigured: Bool {
        defaults.bool(forKey: Self.configuredKey)
    }

    /// Key prefix for namespacing progress data per config.
    /// For legacy fireRed+squirtle this produces "fireRed_squirtle" (same as before).
    var progressPrefix: String {
        "\(gameId)_\(legacyStarter?.rawValue ?? String(starterDex))"
    }

    // MARK: - Legacy Computed Properties

    /// Returns the legacy GameVersion enum if the current gameId matches one, nil otherwise.
    var legacyVersion: GameVersion? {
        GameVersion(rawValue: gameId)
    }

    /// Returns the legacy Starter enum if the current starterDex matches one, nil otherwise.
    var legacyStarter: Starter? {
        Starter.allCases.first { $0.dexNumber == starterDex }
    }

    /// Legacy accessor — returns legacyVersion or defaults to .fireRed.
    /// Used by existing views that read `gameConfig.version`.
    var version: GameVersion {
        get { legacyVersion ?? .fireRed }
        set { configure(from: newValue, starter: legacyStarter ?? .squirtle) }
    }

    /// Legacy accessor — returns legacyStarter or defaults to .squirtle.
    /// Used by existing views that read `gameConfig.starter`.
    var starter: Starter {
        get { legacyStarter ?? .squirtle }
        set { configure(from: legacyVersion ?? .fireRed, starter: newValue) }
    }

    // MARK: - Init

    init() {
        // Check for new-format keys first
        if let savedGameId = UserDefaults.standard.string(forKey: Self.gameIdKey) {
            _gameId = Published(initialValue: savedGameId)
            _starterDex = Published(initialValue: UserDefaults.standard.integer(forKey: Self.starterDexKey))
            _gameName = Published(initialValue: UserDefaults.standard.string(forKey: Self.gameNameKey) ?? "")
            _accentColorHex = Published(initialValue: UserDefaults.standard.string(forKey: Self.accentColorHexKey) ?? "#E02D1F")
            _secondaryColorHex = Published(initialValue: UserDefaults.standard.string(forKey: Self.secondaryColorHexKey) ?? "#ED801A")
            _iconName = Published(initialValue: UserDefaults.standard.string(forKey: Self.iconNameKey) ?? "flame.fill")
        } else if let legacyVersionRaw = UserDefaults.standard.string(forKey: Self.legacyVersionKey),
                  let legacyVersion = GameVersion(rawValue: legacyVersionRaw) {
            // Migrate from legacy format
            let legacyStarter = UserDefaults.standard.string(forKey: Self.legacyStarterKey)
                .flatMap(Starter.init(rawValue:)) ?? .squirtle

            _gameId = Published(initialValue: legacyVersion.rawValue)
            _starterDex = Published(initialValue: legacyStarter.dexNumber)
            _gameName = Published(initialValue: legacyVersion.displayName)
            _accentColorHex = Published(initialValue: legacyVersion.accentColorHex)
            _secondaryColorHex = Published(initialValue: legacyVersion.secondaryColorHex)
            _iconName = Published(initialValue: legacyVersion.icon)

            // Persist in new format
            let ud = UserDefaults.standard
            ud.set(legacyVersion.rawValue, forKey: Self.gameIdKey)
            ud.set(legacyStarter.dexNumber, forKey: Self.starterDexKey)
            ud.set(legacyVersion.displayName, forKey: Self.gameNameKey)
            ud.set(legacyVersion.accentColorHex, forKey: Self.accentColorHexKey)
            ud.set(legacyVersion.secondaryColorHex, forKey: Self.secondaryColorHexKey)
            ud.set(legacyVersion.icon, forKey: Self.iconNameKey)
            ud.set(true, forKey: Self.configuredKey)

            // Keep legacy keys so isConfigured logic stays consistent during transition
        } else {
            // Defaults (not yet configured)
            _gameId = Published(initialValue: "fireRed")
            _starterDex = Published(initialValue: 7)
            _gameName = Published(initialValue: "POKÉMON FIRERED")
            _accentColorHex = Published(initialValue: "#E02D1F")
            _secondaryColorHex = Published(initialValue: "#ED801A")
            _iconName = Published(initialValue: "flame.fill")
        }
    }

    // MARK: - Configuration

    func configure(
        gameId: String,
        starterDex: Int,
        gameName: String,
        accentColorHex: String,
        secondaryColorHex: String,
        iconName: String
    ) {
        self.gameId = gameId
        self.starterDex = starterDex
        self.gameName = gameName
        self.accentColorHex = accentColorHex
        self.secondaryColorHex = secondaryColorHex
        self.iconName = iconName
        defaults.set(true, forKey: Self.configuredKey)

        // Also write legacy keys if this is a legacy game, so old code paths work
        if let legacyVer = GameVersion(rawValue: gameId) {
            defaults.set(legacyVer.rawValue, forKey: Self.legacyVersionKey)
        }
        if let legacySt = Starter.allCases.first(where: { $0.dexNumber == starterDex }) {
            defaults.set(legacySt.rawValue, forKey: Self.legacyStarterKey)
        }
    }

    /// Legacy convenience for existing views that still use GameVersion + Starter
    func configure(version: GameVersion, starter: Starter) {
        configure(
            gameId: version.rawValue,
            starterDex: starter.dexNumber,
            gameName: version.displayName,
            accentColorHex: version.accentColorHex,
            secondaryColorHex: version.secondaryColorHex,
            iconName: version.icon
        )
    }

    func unconfigure() {
        // Reset to defaults
        gameId = "fireRed"
        starterDex = 7
        gameName = "POKÉMON FIRERED"
        accentColorHex = "#E02D1F"
        secondaryColorHex = "#ED801A"
        iconName = "flame.fill"

        // Remove all keys so isConfigured returns false
        defaults.removeObject(forKey: Self.configuredKey)
        defaults.removeObject(forKey: Self.gameIdKey)
        defaults.removeObject(forKey: Self.starterDexKey)
        defaults.removeObject(forKey: Self.gameNameKey)
        defaults.removeObject(forKey: Self.accentColorHexKey)
        defaults.removeObject(forKey: Self.secondaryColorHexKey)
        defaults.removeObject(forKey: Self.iconNameKey)
        defaults.removeObject(forKey: Self.legacyVersionKey)
        defaults.removeObject(forKey: Self.legacyStarterKey)
    }

    // MARK: - Helper for legacy configure via setters

    private func configure(from version: GameVersion, starter: Starter) {
        configure(version: version, starter: starter)
    }
}
