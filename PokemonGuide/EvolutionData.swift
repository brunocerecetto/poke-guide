//
//  EvolutionData.swift
//  PokemonGuide
//
//  Cadenas evolutivas de los 151 Pokémon de Kanto.
//

import Foundation

// MARK: - Evolution Method

enum EvolutionMethod {
    case level(Int)
    case stone(String)
    case trade

    var label: String {
        switch self {
        case .level(let n):   return "Nv. \(n)"
        case .stone(let s):   return s
        case .trade:          return "Intercambio"
        }
    }

    var icon: String {
        switch self {
        case .level:  return "arrow.up.circle.fill"
        case .stone:  return "diamond.fill"
        case .trade:  return "arrow.left.arrow.right.circle.fill"
        }
    }
}

// MARK: - Evolution Stage

struct EvolutionStage: Identifiable {
    let id: Int          // dex number
    let name: String
    let method: EvolutionMethod?  // nil for the base form
}

// MARK: - Evolution Chain

struct EvolutionChain: Identifiable {
    let id: Int  // dex number of the base form
    let stages: [EvolutionStage]
    /// Branching evolutions (e.g. Eevee). Each branch is the evolved form.
    let branches: [EvolutionStage]

    var isBranching: Bool { !branches.isEmpty }
}

// MARK: - All Kanto Evolution Chains

struct EvolutionData {
    static let chains: [EvolutionChain] = [
        // Starters
        linear(1, "Bulbasaur", 2, "Ivysaur", .level(16), 3, "Venusaur", .level(32)),
        linear(4, "Charmander", 5, "Charmeleon", .level(16), 6, "Charizard", .level(36)),
        linear(7, "Squirtle", 8, "Wartortle", .level(16), 9, "Blastoise", .level(36)),

        // Bugs
        linear(10, "Caterpie", 11, "Metapod", .level(7), 12, "Butterfree", .level(10)),
        linear(13, "Weedle", 14, "Kakuna", .level(7), 15, "Beedrill", .level(10)),

        // Birds
        linear(16, "Pidgey", 17, "Pidgeotto", .level(18), 18, "Pidgeot", .level(36)),

        // Early routes
        pair(19, "Rattata", 20, "Raticate", .level(20)),
        pair(21, "Spearow", 22, "Fearow", .level(20)),
        pair(23, "Ekans", 24, "Arbok", .level(22)),

        // Pikachu
        pair(25, "Pikachu", 26, "Raichu", .stone("Piedra Trueno")),

        // Sandshrew
        pair(27, "Sandshrew", 28, "Sandslash", .level(22)),

        // Nidoran lines
        linear(29, "Nidoran♀", 30, "Nidorina", .level(16), 31, "Nidoqueen", .stone("Piedra Lunar")),
        linear(32, "Nidoran♂", 33, "Nidorino", .level(16), 34, "Nidoking", .stone("Piedra Lunar")),

        // Clefairy / Jigglypuff
        pair(35, "Clefairy", 36, "Clefable", .stone("Piedra Lunar")),
        pair(37, "Vulpix", 38, "Ninetales", .stone("Piedra Fuego")),
        pair(39, "Jigglypuff", 40, "Wigglytuff", .stone("Piedra Lunar")),

        // Bats
        pair(41, "Zubat", 42, "Golbat", .level(22)),

        // Plants
        linear(43, "Oddish", 44, "Gloom", .level(21), 45, "Vileplume", .stone("Piedra Hoja")),

        // Bugs
        pair(46, "Paras", 47, "Parasect", .level(24)),

        // More bugs / misc
        pair(48, "Venonat", 49, "Venomoth", .level(31)),
        pair(50, "Diglett", 51, "Dugtrio", .level(26)),
        pair(52, "Meowth", 53, "Persian", .level(28)),
        pair(54, "Psyduck", 55, "Golduck", .level(33)),
        pair(56, "Mankey", 57, "Primeape", .level(28)),
        pair(58, "Growlithe", 59, "Arcanine", .stone("Piedra Fuego")),

        // Poliwag
        linear(60, "Poliwag", 61, "Poliwhirl", .level(25), 62, "Poliwrath", .stone("Piedra Agua")),

        // Abra
        linear(63, "Abra", 64, "Kadabra", .level(16), 65, "Alakazam", .trade),

        // Machop
        linear(66, "Machop", 67, "Machoke", .level(28), 68, "Machamp", .trade),

        // Bellsprout
        linear(69, "Bellsprout", 70, "Weepinbell", .level(21), 71, "Victreebel", .stone("Piedra Hoja")),

        // Tentacool
        pair(72, "Tentacool", 73, "Tentacruel", .level(30)),

        // Geodude
        linear(74, "Geodude", 75, "Graveler", .level(25), 76, "Golem", .trade),

        // Ponyta
        pair(77, "Ponyta", 78, "Rapidash", .level(40)),

        // Slowpoke
        pair(79, "Slowpoke", 80, "Slowbro", .level(37)),

        // Magnemite
        pair(81, "Magnemite", 82, "Magneton", .level(30)),

        // Doduo
        pair(84, "Doduo", 85, "Dodrio", .level(31)),

        // Seel
        pair(86, "Seel", 87, "Dewgong", .level(34)),

        // Grimer
        pair(88, "Grimer", 89, "Muk", .level(38)),

        // Shellder
        pair(90, "Shellder", 91, "Cloyster", .stone("Piedra Agua")),

        // Gastly
        linear(92, "Gastly", 93, "Haunter", .level(25), 94, "Gengar", .trade),

        // Drowzee
        pair(96, "Drowzee", 97, "Hypno", .level(26)),

        // Krabby
        pair(98, "Krabby", 99, "Kingler", .level(28)),

        // Voltorb
        pair(100, "Voltorb", 101, "Electrode", .level(30)),

        // Exeggcute
        pair(102, "Exeggcute", 103, "Exeggutor", .stone("Piedra Hoja")),

        // Cubone
        pair(104, "Cubone", 105, "Marowak", .level(28)),

        // Koffing
        pair(109, "Koffing", 110, "Weezing", .level(35)),

        // Rhyhorn
        pair(111, "Rhyhorn", 112, "Rhydon", .level(42)),

        // Horsea
        pair(116, "Horsea", 117, "Seadra", .level(32)),

        // Goldeen
        pair(118, "Goldeen", 119, "Seaking", .level(33)),

        // Staryu
        pair(120, "Staryu", 121, "Starmie", .stone("Piedra Agua")),

        // Magikarp
        pair(129, "Magikarp", 130, "Gyarados", .level(20)),

        // Eevee — branching
        EvolutionChain(
            id: 133,
            stages: [EvolutionStage(id: 133, name: "Eevee", method: nil)],
            branches: [
                EvolutionStage(id: 134, name: "Vaporeon", method: .stone("Piedra Agua")),
                EvolutionStage(id: 135, name: "Jolteon", method: .stone("Piedra Trueno")),
                EvolutionStage(id: 136, name: "Flareon", method: .stone("Piedra Fuego")),
            ]
        ),

        // Omanyte
        pair(138, "Omanyte", 139, "Omastar", .level(40)),

        // Kabuto
        pair(140, "Kabuto", 141, "Kabutops", .level(40)),

        // Dratini
        linear(147, "Dratini", 148, "Dragonair", .level(30), 149, "Dragonite", .level(55)),
    ]

    // MARK: - Convenience Builders

    private static func pair(
        _ id1: Int, _ name1: String,
        _ id2: Int, _ name2: String,
        _ method: EvolutionMethod
    ) -> EvolutionChain {
        EvolutionChain(
            id: id1,
            stages: [
                EvolutionStage(id: id1, name: name1, method: nil),
                EvolutionStage(id: id2, name: name2, method: method),
            ],
            branches: []
        )
    }

    private static func linear(
        _ id1: Int, _ name1: String,
        _ id2: Int, _ name2: String, _ method1: EvolutionMethod,
        _ id3: Int, _ name3: String, _ method2: EvolutionMethod
    ) -> EvolutionChain {
        EvolutionChain(
            id: id1,
            stages: [
                EvolutionStage(id: id1, name: name1, method: nil),
                EvolutionStage(id: id2, name: name2, method: method1),
                EvolutionStage(id: id3, name: name3, method: method2),
            ],
            branches: []
        )
    }
}
