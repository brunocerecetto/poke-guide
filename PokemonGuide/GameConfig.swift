//
//  GameConfig.swift
//  PokemonGuide
//
//  Selección de versión del juego y starter, persistida en UserDefaults.
//

import Foundation
import Combine

// MARK: - Game Version

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
}

// MARK: - Starter

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

// MARK: - Game Config

class GameConfig: ObservableObject {
    private let defaults = UserDefaults.standard
    private static let versionKey = "gameVersion"
    private static let starterKey = "selectedStarter"

    @Published var version: GameVersion {
        didSet { defaults.set(version.rawValue, forKey: Self.versionKey) }
    }

    @Published var starter: Starter {
        didSet { defaults.set(starter.rawValue, forKey: Self.starterKey) }
    }

    var isConfigured: Bool {
        defaults.string(forKey: Self.versionKey) != nil
            && defaults.string(forKey: Self.starterKey) != nil
    }

    /// Key prefix for namespacing progress data per config
    var progressPrefix: String {
        "\(version.rawValue)_\(starter.rawValue)"
    }

    init() {
        let savedVersion = UserDefaults.standard.string(forKey: Self.versionKey)
            .flatMap(GameVersion.init(rawValue:)) ?? .fireRed
        let savedStarter = UserDefaults.standard.string(forKey: Self.starterKey)
            .flatMap(Starter.init(rawValue:)) ?? .squirtle

        _version = Published(initialValue: savedVersion)
        _starter = Published(initialValue: savedStarter)
    }

    func configure(version: GameVersion, starter: Starter) {
        self.version = version
        self.starter = starter
    }

    func unconfigure() {
        // Reset published properties first (triggers didSet → writes defaults)
        version = .fireRed
        starter = .squirtle
        // Then remove keys so isConfigured returns false
        defaults.removeObject(forKey: Self.versionKey)
        defaults.removeObject(forKey: Self.starterKey)
    }
}
