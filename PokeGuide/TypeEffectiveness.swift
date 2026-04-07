//
//  TypeEffectiveness.swift
//  PokemonGuide
//
//  Datos de efectividad de tipos Gen 6+ (18 tipos incluyendo Dark y Fairy).
//  Fuente canónica para TeamBuilderView y TypeChartView.
//

import Foundation

struct TypeEffectiveness {

    // MARK: - Core lookup

    /// Returns damage multiplier: 2.0 (super effective), 1.0 (neutral), 0.5 (not very effective), or 0.0 (immune)
    static func multiplier(attacking: PokemonType, defending: PokemonType) -> Double {
        chart[attacking]?[defending] ?? 1.0
    }

    // MARK: - Convenience queries

    /// All types that `attackingType` is super effective against
    static func superEffective(_ type: PokemonType) -> [PokemonType] {
        PokemonType.allCases.filter { multiplier(attacking: type, defending: $0) >= 2.0 }
    }

    /// All types that a Pokemon with the given type combination is weak to (combined multiplier > 1)
    static func weaknesses(of types: [PokemonType]) -> [PokemonType] {
        PokemonType.allCases.filter { attacking in
            let combined = types.reduce(1.0) { $0 * multiplier(attacking: attacking, defending: $1) }
            return combined > 1.0
        }
    }

    /// All types that a Pokemon with the given type combination resists (combined multiplier < 1, including immunities)
    static func resistances(of types: [PokemonType]) -> [PokemonType] {
        PokemonType.allCases.filter { attacking in
            let combined = types.reduce(1.0) { $0 * multiplier(attacking: attacking, defending: $1) }
            return combined < 1.0
        }
    }

    /// Combined defensive multiplier for a type combination against an attacking type
    static func defensiveMultiplier(attackingType: PokemonType, defendingTypes: [PokemonType]) -> Double {
        defendingTypes.reduce(1.0) { $0 * multiplier(attacking: attackingType, defending: $1) }
    }

    // MARK: - Gen 6+ Type Chart (18 types, with Dark and Fairy)

    /// Only stores non-1.0 multipliers for compactness. Missing entries default to 1.0.
    private static let chart: [PokemonType: [PokemonType: Double]] = [
        .normal: [
            .rock: 0.5, .ghost: 0.0, .steel: 0.5
        ],
        .fire: [
            .fire: 0.5, .water: 0.5, .grass: 2.0, .ice: 2.0,
            .bug: 2.0, .rock: 0.5, .dragon: 0.5, .steel: 2.0
        ],
        .water: [
            .fire: 2.0, .water: 0.5, .grass: 0.5, .ground: 2.0,
            .rock: 2.0, .dragon: 0.5
        ],
        .grass: [
            .fire: 0.5, .water: 2.0, .grass: 0.5, .poison: 0.5,
            .ground: 2.0, .flying: 0.5, .bug: 0.5, .rock: 2.0,
            .dragon: 0.5, .steel: 0.5
        ],
        .electric: [
            .water: 2.0, .grass: 0.5, .electric: 0.5, .ground: 0.0,
            .flying: 2.0, .dragon: 0.5
        ],
        .ice: [
            .fire: 0.5, .water: 0.5, .grass: 2.0, .ice: 0.5,
            .ground: 2.0, .flying: 2.0, .dragon: 2.0, .steel: 0.5
        ],
        .fighting: [
            .normal: 2.0, .ice: 2.0, .poison: 0.5, .flying: 0.5,
            .psychic: 0.5, .bug: 0.5, .rock: 2.0, .ghost: 0.0,
            .dark: 2.0, .steel: 2.0, .fairy: 0.5
        ],
        .poison: [
            .grass: 2.0, .poison: 0.5, .ground: 0.5, .rock: 0.5,
            .ghost: 0.5, .steel: 0.0, .fairy: 2.0
        ],
        .ground: [
            .fire: 2.0, .electric: 2.0, .grass: 0.5, .poison: 2.0,
            .flying: 0.0, .bug: 0.5, .rock: 2.0, .steel: 2.0
        ],
        .flying: [
            .electric: 0.5, .grass: 2.0, .fighting: 2.0, .bug: 2.0,
            .rock: 0.5, .steel: 0.5
        ],
        .psychic: [
            .fighting: 2.0, .poison: 2.0, .psychic: 0.5, .dark: 0.0,
            .steel: 0.5
        ],
        .bug: [
            .fire: 0.5, .grass: 2.0, .fighting: 0.5, .poison: 0.5,
            .flying: 0.5, .psychic: 2.0, .ghost: 0.5, .dark: 2.0,
            .steel: 0.5, .fairy: 0.5
        ],
        .rock: [
            .fire: 2.0, .ice: 2.0, .fighting: 0.5, .ground: 0.5,
            .flying: 2.0, .bug: 2.0, .steel: 0.5
        ],
        .ghost: [
            .normal: 0.0, .psychic: 2.0, .ghost: 2.0, .dark: 0.5
        ],
        .dragon: [
            .dragon: 2.0, .steel: 0.5, .fairy: 0.0
        ],
        .dark: [
            .fighting: 0.5, .psychic: 2.0, .ghost: 2.0, .dark: 0.5,
            .fairy: 0.5
        ],
        .steel: [
            .fire: 0.5, .water: 0.5, .electric: 0.5, .ice: 2.0,
            .rock: 2.0, .steel: 0.5, .fairy: 2.0
        ],
        .fairy: [
            .fire: 0.5, .fighting: 2.0, .poison: 0.5, .dragon: 2.0,
            .dark: 2.0, .steel: 0.5
        ]
    ]
}
