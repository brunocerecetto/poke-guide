//
//  TeamAnalysis.swift
//  PokeGuide
//
//  Pure analysis functions for team coverage, stats, and warnings.
//

import SwiftUI

enum TeamAnalysis {
    static func offensiveCoverage(for team: [PokemonEntry]) -> [PokemonType] {
        var covered = Set<PokemonType>()
        for member in team {
            for attackType in member.types {
                for target in TypeEffectiveness.superEffective(attackType) {
                    covered.insert(target)
                }
            }
        }
        return PokemonType.allCases.filter { covered.contains($0) }
    }

    static func defensiveWeaknesses(for team: [PokemonEntry]) -> [PokemonType] {
        var weakCounts: [PokemonType: Int] = [:]
        for member in team {
            for weakness in TypeEffectiveness.weaknesses(of: member.types) {
                weakCounts[weakness, default: 0] += 1
            }
        }
        let threshold = max(1, team.count / 2)
        return PokemonType.allCases.filter { (weakCounts[$0] ?? 0) >= threshold }
    }

    static func defensiveResistances(for team: [PokemonEntry]) -> [PokemonType] {
        var resistCounts: [PokemonType: Int] = [:]
        for member in team {
            for resistance in TypeEffectiveness.resistances(of: member.types) {
                resistCounts[resistance, default: 0] += 1
            }
        }
        let threshold = max(1, team.count / 2)
        return PokemonType.allCases.filter { (resistCounts[$0] ?? 0) >= threshold }
    }

    static func averageStats(for team: [PokemonEntry]) -> PokemonStats {
        guard !team.isEmpty else {
            return PokemonStats(hp: 0, attack: 0, defense: 0, spAttack: 0, spDefense: 0, speed: 0)
        }
        let count = team.count
        return PokemonStats(
            hp: team.map(\.stats.hp).reduce(0, +) / count,
            attack: team.map(\.stats.attack).reduce(0, +) / count,
            defense: team.map(\.stats.defense).reduce(0, +) / count,
            spAttack: team.map(\.stats.spAttack).reduce(0, +) / count,
            spDefense: team.map(\.stats.spDefense).reduce(0, +) / count,
            speed: team.map(\.stats.speed).reduce(0, +) / count
        )
    }

    static func generateWarnings(for team: [PokemonEntry]) -> [String] {
        var warnings: [String] = []

        let covered = Set(offensiveCoverage(for: team))
        let uncovered = PokemonType.allCases.filter { !covered.contains($0) }
        for type in uncovered {
            warnings.append("No tenés cobertura ofensiva contra tipo \(type.rawValue.capitalized).")
        }

        var weakCounts: [PokemonType: Int] = [:]
        for member in team {
            for weakness in TypeEffectiveness.weaknesses(of: member.types) {
                weakCounts[weakness, default: 0] += 1
            }
        }
        for type in PokemonType.allCases {
            if (weakCounts[type] ?? 0) >= 2 {
                warnings.append("\(weakCounts[type]!) Pokémon débiles a \(type.rawValue.capitalized).")
            }
        }

        var typeCounts: [PokemonType: Int] = [:]
        for member in team {
            for t in member.types { typeCounts[t, default: 0] += 1 }
        }
        for type in PokemonType.allCases {
            if (typeCounts[type] ?? 0) >= 3 {
                warnings.append("Tenés \(typeCounts[type]!) Pokémon de tipo \(type.rawValue.capitalized) — considerá diversificar.")
            }
        }

        let avg = averageStats(for: team)
        if avg.total < 350 && team.count >= 3 {
            warnings.append("El promedio de stats totales es bajo (\(avg.total)). Considerá Pokémon más fuertes.")
        }

        return warnings
    }
}
