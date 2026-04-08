//
//  GameDataBridge.swift
//  PokeGuide
//
//  Bridge layer that loads guide data from GuideRepository (Core Data).
//

import Foundation
import CoreData
import Combine

class GameDataBridge: ObservableObject {
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
        guideRepo?.gyms(gameId: gameId) ?? []
    }

    // MARK: - Team

    func teamRecommendation(starter: String) -> TeamRecommendationDTO? {
        guideRepo?.teamRecommendation(gameId: gameId, starter: starter)
    }

    /// Convenience: team members for the current starter
    var team: [TeamMemberDTO] {
        let starterName = StarterInfo.starters(for: [starterDex]).first?.name.lowercased()
            ?? Starter.allCases.first { $0.dexNumber == starterDex }?.rawValue
            ?? "squirtle"
        return teamRecommendation(starter: starterName)?.members ?? []
    }

    // MARK: - Route Sections

    var routeSections: [RouteSectionDTO] {
        guideRepo?.routeSections(gameId: gameId) ?? []
    }

    // MARK: - Elite Four

    var eliteFour: [EliteFourMemberDTO] {
        guideRepo?.eliteFour(gameId: gameId) ?? []
    }

    // MARK: - Pre-League / Postgame Checklists

    var preLeagueChecklist: [ChecklistStepDTO] {
        guideRepo?.preLeagueChecklist(gameId: gameId) ?? []
    }

    var postgameChecklist: [ChecklistStepDTO] {
        guideRepo?.postgameChecklist(gameId: gameId) ?? []
    }

    // MARK: - Captures

    var captures: [KeyCaptureDTO] {
        guideRepo?.captures(gameId: gameId) ?? []
    }

    // MARK: - HMs & TMs

    var hmEntries: [HMEntryDTO] {
        guideRepo?.hmEntries(gameId: gameId) ?? []
    }

    var tmEntries: [TMEntryDTO] {
        guideRepo?.tmEntries(gameId: gameId) ?? []
    }

    // MARK: - Tips

    var tips: [TipDTO] {
        guideRepo?.tips(gameId: gameId) ?? []
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
