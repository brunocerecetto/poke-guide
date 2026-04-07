//
//  GameDataBridge.swift
//  PokeGuide
//
//  Bridge layer that loads guide data from GuideRepository (Core Data)
//  when available, falling back to legacy static GameData/RivalData.
//

import Foundation
import CoreData
import Combine

private struct BundledTeamMemberJSON: Codable {
    let name: String
    let moves: [String]
    let notes: String
    let emoji: String
}

private struct BundledTeamJSON: Codable {
    let members: [BundledTeamMemberJSON]
}

class GameDataBridge: ObservableObject {
    // No @Published properties needed — data is currently static per session.
    // This dummy property satisfies ObservableObject synthesis under @MainActor isolation.
    @Published private var _version: Int = 0

    private let guideRepo: GuideRepository?
    private let gameId: String
    private let starterDex: Int

    init(gameId: String, starterDex: Int, context: NSManagedObjectContext?) {
        self.gameId = gameId
        self.starterDex = starterDex
        if let context {
            self.guideRepo = GuideRepository(context: context)
        } else {
            self.guideRepo = nil
        }
    }

    // MARK: - Gyms

    var gyms: [GymDTO] {
        if let repoGyms = guideRepo?.gyms(gameId: gameId), !repoGyms.isEmpty {
            return repoGyms
        }
        return GameData.gyms.enumerated().map { i, g in
            GymDTO(id: i, name: g.name, leader: g.leader, levelRange: g.levelRange, note: g.note, badge: g.badge, badgeSpriteId: i + 1)
        }
    }

    // MARK: - Team

    func teamRecommendation(starter: String) -> TeamRecommendationDTO? {
        if let repoRec = guideRepo?.teamRecommendation(gameId: gameId, starter: starter), !repoRec.members.isEmpty {
            return repoRec
        }
        return loadTeamFromBundle(starter: starter)
    }

    /// Convenience: team members for the current starter
    var team: [TeamMemberDTO] {
        let starterName = Starter.allCases.first { $0.dexNumber == starterDex }?.rawValue ?? "squirtle"
        return teamRecommendation(starter: starterName)?.members ?? []
    }

    private func loadTeamFromBundle(starter: String) -> TeamRecommendationDTO? {
        let fileName = "team-\(starter)"

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode(BundledTeamJSON.self, from: data) else {
            return nil
        }

        let members = json.members.enumerated().map { index, m in
            TeamMemberDTO(
                id: index,
                name: m.name,
                dexNumber: PokedexData.kanto.first { $0.name == m.name }?.id ?? 0,
                moves: m.moves,
                notes: m.notes,
                emoji: m.emoji
            )
        }
        return TeamRecommendationDTO(starterCondition: starter, members: members)
    }

    // MARK: - Route Sections

    var routeSections: [RouteSectionDTO] {
        if let repoSections = guideRepo?.routeSections(gameId: gameId), !repoSections.isEmpty {
            return repoSections
        }
        return GameData.routeSections.enumerated().map { i, s in
            RouteSectionDTO(
                id: i,
                title: s.title,
                steps: s.steps.map { RouteStepDTO(id: $0.id, text: $0.text) }
            )
        }
    }

    // MARK: - Elite Four

    var eliteFour: [EliteFourMemberDTO] {
        if let repoMembers = guideRepo?.eliteFour(gameId: gameId), !repoMembers.isEmpty {
            return repoMembers
        }
        return GameData.eliteFour.enumerated().map { i, m in
            EliteFourMemberDTO(id: i, name: m.name, strategy: m.strategy, levels: m.levels)
        }
    }

    // MARK: - Pre-League / Postgame Checklists

    var preLeagueChecklist: [ChecklistStepDTO] {
        if let repoSteps = guideRepo?.preLeagueChecklist(gameId: gameId), !repoSteps.isEmpty {
            return repoSteps
        }
        return GameData.preLeagueChecklist.map { ChecklistStepDTO(id: $0.id, text: $0.text) }
    }

    var postgameChecklist: [ChecklistStepDTO] {
        if let repoSteps = guideRepo?.postgameChecklist(gameId: gameId), !repoSteps.isEmpty {
            return repoSteps
        }
        return GameData.postgame.map { ChecklistStepDTO(id: $0.id, text: $0.text) }
    }

    // MARK: - Captures

    var captures: [KeyCaptureDTO] {
        if let repoCaptures = guideRepo?.captures(gameId: gameId), !repoCaptures.isEmpty {
            return repoCaptures
        }
        return GameData.captures.enumerated().map { i, c in
            KeyCaptureDTO(id: i, pokemon: c.pokemon, location: c.location, note: c.note)
        }
    }

    // MARK: - HMs & TMs

    var hmEntries: [HMEntryDTO] {
        if let repoEntries = guideRepo?.hmEntries(gameId: gameId), !repoEntries.isEmpty {
            return repoEntries
        }
        return GameData.hms.enumerated().map { i, h in
            HMEntryDTO(id: i, hm: h.hm, pokemon: h.pokemon, location: h.location)
        }
    }

    var tmEntries: [TMEntryDTO] {
        if let repoEntries = guideRepo?.tmEntries(gameId: gameId), !repoEntries.isEmpty {
            return repoEntries
        }
        return GameData.tms.enumerated().map { i, t in
            TMEntryDTO(id: i, tm: t.tm, target: t.target, origin: t.origin)
        }
    }

    // MARK: - Tips

    var tips: [TipDTO] {
        if let repoTips = guideRepo?.tips(gameId: gameId), !repoTips.isEmpty {
            return repoTips
        }
        return GameData.tips.enumerated().map { i, t in
            TipDTO(id: i, pokemon: t.pokemon, rule: t.rule)
        }
    }

    // MARK: - Counts (for ProgressManager)

    var totalCheckable: Int {
        gyms.count
        + routeSections.flatMap(\.steps).count
        + eliteFour.count
        + preLeagueChecklist.count
        + postgameChecklist.count
    }
}
