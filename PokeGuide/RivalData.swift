//
//  RivalData.swift
//  PokemonGuide
//
//  Datos estáticos del equipo del rival en cada encuentro.
//  El starter del rival depende de la elección del jugador.
//

import Foundation

// MARK: - Models

struct RivalPokemon: Identifiable {
    let id = UUID()
    let name: String
    let level: Int
    let dexNumber: Int

    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(dexNumber).png")
    }
}

struct RivalEncounter: Identifiable {
    let id: String
    let location: String
    let icon: String
    let team: (Starter) -> [RivalPokemon]
}

// MARK: - Static Data

struct RivalData {

    /// The rival's starter based on the player's choice.
    static func rivalStarter(for playerStarter: Starter) -> Starter {
        switch playerStarter {
        case .squirtle:   return .bulbasaur
        case .bulbasaur:  return .charmander
        case .charmander: return .squirtle
        }
    }

    // MARK: - Helper: starter evolution lines by dex number

    /// Returns (base, stage1, stage2) dex numbers for the rival's starter line.
    private static func rivalLine(for playerStarter: Starter) -> (base: Int, mid: Int, final: Int) {
        switch playerStarter {
        case .squirtle:   return (1, 2, 3)      // Bulbasaur → Ivysaur → Venusaur
        case .bulbasaur:  return (4, 5, 6)      // Charmander → Charmeleon → Charizard
        case .charmander: return (7, 8, 9)      // Squirtle → Wartortle → Blastoise
        }
    }

    private static func rivalLineName(for playerStarter: Starter) -> (base: String, mid: String, final: String) {
        switch playerStarter {
        case .squirtle:   return ("Bulbasaur", "Ivysaur", "Venusaur")
        case .bulbasaur:  return ("Charmander", "Charmeleon", "Charizard")
        case .charmander: return ("Squirtle", "Wartortle", "Blastoise")
        }
    }

    /// The 4th-slot Pokemon varies by player starter in encounters 4-6.
    /// - Squirtle (rival has Bulbasaur line): Exeggcute/Exeggutor
    /// - Bulbasaur (rival has Charmander line): Growlithe/Arcanine
    /// - Charmander (rival has Squirtle line): Gyarados already covers water; uses Exeggcute/Exeggutor
    /// Actually in FRLG the rival's variable slot depends on starter:
    /// - Rival Venusaur path: Growlithe → Arcanine
    /// - Rival Charizard path: Exeggcute → Exeggutor
    /// - Rival Blastoise path: Growlithe → Arcanine
    private static func variableSlot(for playerStarter: Starter) -> (name4: String, dex4: Int, name4Evo: String, dex4Evo: Int) {
        switch playerStarter {
        case .squirtle:   return ("Growlithe", 58, "Arcanine", 59)
        case .bulbasaur:  return ("Exeggcute", 102, "Exeggutor", 103)
        case .charmander: return ("Growlithe", 58, "Arcanine", 59)
        }
    }

    // MARK: - Encounters

    static let encounters: [RivalEncounter] = [

        // 1. Route 22 (1st) — solo starter Lv 5
        RivalEncounter(
            id: "rival_route22_1",
            location: "Ruta 22 (1er encuentro)",
            icon: "figure.walk"
        ) { starter in
            let line = rivalLineName(for: starter)
            let dex = rivalLine(for: starter)
            return [
                RivalPokemon(name: line.base, level: 5, dexNumber: dex.base),
            ]
        },

        // 2. Cerulean City — Lv 17-18
        RivalEncounter(
            id: "rival_cerulean",
            location: "Ciudad Celeste",
            icon: "building.2.fill"
        ) { starter in
            let line = rivalLineName(for: starter)
            let dex = rivalLine(for: starter)
            return [
                RivalPokemon(name: "Pidgeotto", level: 17, dexNumber: 17),
                RivalPokemon(name: "Abra", level: 16, dexNumber: 63),
                RivalPokemon(name: "Rattata", level: 15, dexNumber: 19),
                RivalPokemon(name: line.mid, level: 18, dexNumber: dex.mid),
            ]
        },

        // 3. SS Anne — Lv 19-22
        RivalEncounter(
            id: "rival_ssanne",
            location: "SS Anne",
            icon: "ferry.fill"
        ) { starter in
            let line = rivalLineName(for: starter)
            let dex = rivalLine(for: starter)
            return [
                RivalPokemon(name: "Pidgeotto", level: 19, dexNumber: 17),
                RivalPokemon(name: "Raticate", level: 16, dexNumber: 20),
                RivalPokemon(name: "Kadabra", level: 18, dexNumber: 64),
                RivalPokemon(name: line.mid, level: 20, dexNumber: dex.mid),
            ]
        },

        // 4. Pokemon Tower — Lv 25-28
        RivalEncounter(
            id: "rival_pokemon_tower",
            location: "Torre Pokémon",
            icon: "building.columns.fill"
        ) { starter in
            let line = rivalLineName(for: starter)
            let dex = rivalLine(for: starter)
            let variable = variableSlot(for: starter)
            return [
                RivalPokemon(name: "Pidgeotto", level: 25, dexNumber: 17),
                RivalPokemon(name: "Gyarados", level: 23, dexNumber: 130),
                RivalPokemon(name: variable.name4, level: 22, dexNumber: variable.dex4),
                RivalPokemon(name: "Kadabra", level: 20, dexNumber: 64),
                RivalPokemon(name: line.mid, level: 25, dexNumber: dex.mid),
            ]
        },

        // 5. Silph Co — Lv 37-40
        RivalEncounter(
            id: "rival_silph",
            location: "Silph Co.",
            icon: "building.fill"
        ) { starter in
            let line = rivalLineName(for: starter)
            let dex = rivalLine(for: starter)
            let variable = variableSlot(for: starter)
            return [
                RivalPokemon(name: "Pidgeot", level: 37, dexNumber: 18),
                RivalPokemon(name: "Gyarados", level: 35, dexNumber: 130),
                RivalPokemon(name: variable.name4, level: 35, dexNumber: variable.dex4),
                RivalPokemon(name: "Alakazam", level: 35, dexNumber: 65),
                RivalPokemon(name: line.final, level: 40, dexNumber: dex.final),
            ]
        },

        // 6. Route 22 (2nd) — Lv 47-53
        RivalEncounter(
            id: "rival_route22_2",
            location: "Ruta 22 (2do encuentro)",
            icon: "figure.walk"
        ) { starter in
            let line = rivalLineName(for: starter)
            let dex = rivalLine(for: starter)
            let variable = variableSlot(for: starter)
            return [
                RivalPokemon(name: "Pidgeot", level: 47, dexNumber: 18),
                RivalPokemon(name: "Rhyhorn", level: 45, dexNumber: 111),
                RivalPokemon(name: "Gyarados", level: 45, dexNumber: 130),
                RivalPokemon(name: variable.name4, level: 45, dexNumber: variable.dex4),
                RivalPokemon(name: "Alakazam", level: 47, dexNumber: 65),
                RivalPokemon(name: line.final, level: 53, dexNumber: dex.final),
            ]
        },

        // 7. Champion — Lv 59-63
        RivalEncounter(
            id: "rival_champion",
            location: "Campeón",
            icon: "trophy.fill"
        ) { starter in
            let line = rivalLineName(for: starter)
            let dex = rivalLine(for: starter)
            let variable = variableSlot(for: starter)
            return [
                RivalPokemon(name: "Pidgeot", level: 59, dexNumber: 18),
                RivalPokemon(name: "Rhydon", level: 59, dexNumber: 112),
                RivalPokemon(name: "Gyarados", level: 61, dexNumber: 130),
                RivalPokemon(name: variable.name4Evo, level: 59, dexNumber: variable.dex4Evo),
                RivalPokemon(name: "Alakazam", level: 57, dexNumber: 65),
                RivalPokemon(name: line.final, level: 63, dexNumber: dex.final),
            ]
        },
    ]
}
