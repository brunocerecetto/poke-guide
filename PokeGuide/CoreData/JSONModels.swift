//
//  JSONModels.swift
//  PokeGuide
//
//  Codable structs matching the JSON file schemas used for seeding.
//

import Foundation

// MARK: - National Dex

struct PokemonJSON: Codable {
    let dexNumber: Int
    let name: String
    let types: [String]
    let stats: StatsJSON
    let generation: Int

    struct StatsJSON: Codable {
        let hp: Int
        let attack: Int
        let defense: Int
        let spAttack: Int
        let spDefense: Int
        let speed: Int
    }
}

// MARK: - Evolutions

struct EvolutionChainJSON: Codable {
    let stages: [EvolutionStageJSON]
}

struct EvolutionStageJSON: Codable {
    let fromDexNumber: Int
    let toDexNumber: Int
    let method: String
    let detail: String
}

// MARK: - Game Definition

struct GameJSON: Codable {
    let id: String
    let name: String
    let generation: Int
    let region: String
    let releaseYear: Int
    let platform: String
    let accentColorHex: String
    let secondaryColorHex: String
    let iconName: String
    let starterDexNumbers: [Int]
    let gymCount: Int
    let hasEliteFour: Bool
    let hasChampion: Bool
    let regionalDex: [RegionalDexEntryJSON]
    let versionExclusives: [VersionExclusiveJSON]?
}

struct RegionalDexEntryJSON: Codable {
    let regionalDexNumber: Int
    let nationalDexNumber: Int
    let location: String
}

struct VersionExclusiveJSON: Codable {
    let nationalDexNumber: Int
    let availability: String
    let location: String
    let regionalDexNumber: Int
}

// MARK: - Guide: Route

struct GuideRouteJSON: Codable {
    let sections: [GuideRouteSectionJSON]
}

struct GuideRouteSectionJSON: Codable {
    let title: String
    let steps: [GuideRouteStepJSON]
}

struct GuideRouteStepJSON: Codable {
    let stepId: String
    let text: String
}

// MARK: - Guide: Gyms

struct GuideGymJSON: Codable {
    let name: String
    let leader: String
    let levelRange: String
    let note: String
    let badge: String
}

// MARK: - Guide: Team Recommendations

struct GuideTeamJSON: Codable {
    let recommendations: [GuideTeamRecommendationJSON]
}

struct GuideTeamRecommendationJSON: Codable {
    let starterCondition: String
    let members: [GuideTeamMemberJSON]
}

struct GuideTeamMemberJSON: Codable {
    let name: String
    let moves: [String]
    let notes: String
    let emoji: String
}

// MARK: - Guide: Rival Encounters

struct GuideRivalJSON: Codable {
    let encounters: [GuideRivalEncounterJSON]
}

struct GuideRivalEncounterJSON: Codable {
    let location: String
    let iconName: String
    let team: [GuideRivalPokemonJSON]
}

struct GuideRivalPokemonJSON: Codable {
    let name: String
    let level: Int
    let dexNumber: Int
    let starterCondition: String?
}

// MARK: - Guide: Elite Four

struct GuideEliteFourJSON: Codable {
    let members: [GuideEliteFourMemberJSON]
}

struct GuideEliteFourMemberJSON: Codable {
    let name: String
    let strategy: String
    let levels: String
}

// MARK: - Guide: Tips

struct GuideTipJSON: Codable {
    let pokemon: String
    let rule: String
}

// MARK: - Guide: Key Captures

struct GuideCaptureJSON: Codable {
    let pokemon: String
    let location: String
    let note: String
}

// MARK: - Guide: HMs & TMs

struct GuideHMTMJSON: Codable {
    let hmEntries: [GuideHMEntryJSON]
    let tmEntries: [GuideTMEntryJSON]
}

struct GuideHMEntryJSON: Codable {
    let hm: String
    let pokemon: String
    let location: String
}

struct GuideTMEntryJSON: Codable {
    let tm: String
    let target: String
    let origin: String
}

// MARK: - Guide: Pre-League & Postgame

struct GuidePreLeagueJSON: Codable {
    let steps: [GuideStepJSON]
}

struct GuidePostgameJSON: Codable {
    let steps: [GuideStepJSON]
}

struct GuideStepJSON: Codable {
    let stepId: String
    let text: String
}
