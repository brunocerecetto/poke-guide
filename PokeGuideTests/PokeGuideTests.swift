//
//  PokeGuideTests.swift
//  PokeGuideTests
//

import Foundation
import Testing
@testable import PokeGuide

// MARK: - TypeEffectiveness Tests

struct TypeEffectivenessTests {

    @Test func fireIsSuperEffectiveAgainstGrass() {
        let multiplier = TypeEffectiveness.multiplier(attacking: .fire, defending: .grass)
        #expect(multiplier == 2.0)
    }

    @Test func waterIsNotVeryEffectiveAgainstGrass() {
        let multiplier = TypeEffectiveness.multiplier(attacking: .water, defending: .grass)
        #expect(multiplier == 0.5)
    }

    @Test func normalIsImmuneToGhost() {
        let multiplier = TypeEffectiveness.multiplier(attacking: .normal, defending: .ghost)
        #expect(multiplier == 0.0)
    }

    @Test func electricIsImmuneToGround() {
        let multiplier = TypeEffectiveness.multiplier(attacking: .electric, defending: .ground)
        #expect(multiplier == 0.0)
    }

    @Test func neutralMatchupReturnsOne() {
        let multiplier = TypeEffectiveness.multiplier(attacking: .fire, defending: .normal)
        #expect(multiplier == 1.0)
    }

    @Test func superEffectiveListForFire() {
        let effective = TypeEffectiveness.superEffective(.fire)
        #expect(effective.contains(.grass))
        #expect(effective.contains(.ice))
        #expect(effective.contains(.bug))
        #expect(effective.contains(.steel))
        #expect(!effective.contains(.water))
    }

    @Test func weaknessesForDualType() {
        // Grass/Poison is weak to Fire, Ice, Flying, Psychic
        let weaknesses = TypeEffectiveness.weaknesses(of: [.grass, .poison])
        #expect(weaknesses.contains(.fire))
        #expect(weaknesses.contains(.psychic))
        #expect(!weaknesses.contains(.water))
    }

    @Test func resistancesForSingleType() {
        let resistances = TypeEffectiveness.resistances(of: [.steel])
        #expect(resistances.contains(.normal))
        #expect(resistances.contains(.fairy))
        #expect(!resistances.contains(.fire))
    }

    @Test func defensiveMultiplierForDualType() {
        // Fire attacking Grass/Ice = 2.0 * 2.0 = 4.0
        let mult = TypeEffectiveness.defensiveMultiplier(attackingType: .fire, defendingTypes: [.grass, .ice])
        #expect(mult == 4.0)
    }

    @Test func fairyImmuneToDragon() {
        let multiplier = TypeEffectiveness.multiplier(attacking: .dragon, defending: .fairy)
        #expect(multiplier == 0.0)
    }

    @Test func fightingIsImmuneToGhost() {
        let multiplier = TypeEffectiveness.multiplier(attacking: .fighting, defending: .ghost)
        #expect(multiplier == 0.0)
    }

    @Test func allTypesHaveChartEntries() {
        for type in PokemonType.allCases {
            // Every type should have at least one non-1.0 matchup (SE, NVE, or immune)
            let hasNonNeutral = PokemonType.allCases.contains {
                TypeEffectiveness.multiplier(attacking: type, defending: $0) != 1.0
            }
            #expect(hasNonNeutral,
                    "Type \(type.rawValue) should have non-trivial matchups")
        }
    }
}

// MARK: - GameConfig Tests

struct GameConfigTests {

    @Test func defaultConstants() {
        #expect(GameConfig.defaultAccentColorHex == "#E02D1F")
        #expect(GameConfig.defaultSecondaryColorHex == "#ED801A")
        #expect(GameConfig.defaultIconName == "flame.fill")
        #expect(GameConfig.defaultGameName == "POKÉMON FIRERED")
    }

    @Test func legacyVersionMapping() {
        #expect(GameVersion.fireRed.gameId == "fireRed")
        #expect(GameVersion.leafGreen.gameId == "leafGreen")
    }

    @Test func starterDexNumbers() {
        #expect(Starter.bulbasaur.dexNumber == 1)
        #expect(Starter.charmander.dexNumber == 4)
        #expect(Starter.squirtle.dexNumber == 7)
    }

    @Test func starterTypeMapping() {
        #expect(Starter.bulbasaur.type == .grass)
        #expect(Starter.charmander.type == .fire)
        #expect(Starter.squirtle.type == .water)
    }

    @Test func gameVersionColors() {
        #expect(GameVersion.fireRed.accentColorHex == "#BC0100")
        #expect(GameVersion.leafGreen.accentColorHex == "#2EA652")
    }
}

// MARK: - ProgressManager Tests

@MainActor
struct ProgressManagerTests {

    @Test func toggleGym() {
        let manager = ProgressManager(prefix: "test_\(UUID().uuidString)")
        #expect(!manager.isGymCompleted("Brock"))

        manager.toggleGym("Brock")
        #expect(manager.isGymCompleted("Brock"))

        manager.toggleGym("Brock")
        #expect(!manager.isGymCompleted("Brock"))
    }

    @Test func toggleRouteStep() {
        let manager = ProgressManager(prefix: "test_\(UUID().uuidString)")
        #expect(!manager.isRouteStepCompleted("step1"))

        manager.toggleRouteStep("step1")
        #expect(manager.isRouteStepCompleted("step1"))
    }

    @Test func cyclePokemonStatus() {
        let manager = ProgressManager(prefix: "test_\(UUID().uuidString)")
        #expect(manager.pokemonStatus(for: 1) == .notSeen)

        manager.cyclePokemonStatus(for: 1)
        #expect(manager.pokemonStatus(for: 1) == .seen)

        manager.cyclePokemonStatus(for: 1)
        #expect(manager.pokemonStatus(for: 1) == .caught)
    }

    @Test func resetClearsAll() {
        let manager = ProgressManager(prefix: "test_\(UUID().uuidString)")
        manager.toggleGym("Brock")
        manager.toggleRouteStep("step1")
        manager.toggleLeague("Lorelei")

        manager.resetAll()
        #expect(manager.completedGyms.isEmpty)
        #expect(manager.completedRouteSteps.isEmpty)
        #expect(manager.completedLeague.isEmpty)
    }

    @Test func totalCompletedCounts() {
        let manager = ProgressManager(prefix: "test_\(UUID().uuidString)")
        manager.toggleGym("Brock")
        manager.toggleGym("Misty")
        manager.toggleRouteStep("step1")

        #expect(manager.totalCompleted == 3)
    }

    @Test func customTeamSlot() {
        let manager = ProgressManager(prefix: "test_\(UUID().uuidString)")
        manager.setCustomTeamSlot(0, dexNumber: 25)

        #expect(manager.customTeamDexNumbers.first == 25)
    }
}

// MARK: - PokemonType Tests

struct PokemonTypeTests {

    @Test func allCasesContains18Types() {
        #expect(PokemonType.allCases.count == 18)
    }

    @Test func rawValueRoundTrips() {
        for type in PokemonType.allCases {
            #expect(PokemonType(rawValue: type.rawValue) == type)
        }
    }
}

// MARK: - StarterInfo Tests

struct StarterInfoTests {

    @Test func lookupKnownStarters() {
        let starters = StarterInfo.starters(for: [1, 4, 7])
        #expect(starters.count == 3)
        #expect(starters[0].name == "Bulbasaur")
        #expect(starters[1].name == "Charmander")
        #expect(starters[2].name == "Squirtle")
    }

    @Test func lookupUnknownDexReturnsEmpty() {
        let starters = StarterInfo.starters(for: [9999])
        #expect(starters.isEmpty)
    }

    @Test func allGenerationStartersExist() {
        let allDex = [1, 4, 7, 25, 152, 155, 158, 252, 255, 258, 387, 390, 393,
                      495, 498, 501, 650, 653, 656, 722, 725, 728, 810, 813, 816, 906, 909, 912]
        let starters = StarterInfo.starters(for: allDex)
        #expect(starters.count == allDex.count)
    }
}
