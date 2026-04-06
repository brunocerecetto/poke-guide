//
//  DataSeeder.swift
//  PokemonGuide
//
//  Seeds Core Data from bundled JSON files on first launch.
//  All seeding runs on a background context for performance.
//

import CoreData
import Foundation

final class DataSeeder {
    private static let seedVersionKey = "dataSeeded_v1"

    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    // MARK: - Public API

    /// Seeds all data if this version hasn't been seeded yet.
    /// Call from app launch. Runs on a background context.
    func seedIfNeeded(completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        guard !UserDefaults.standard.bool(forKey: Self.seedVersionKey) else {
            completion(.success(()))
            return
        }

        let context = persistenceController.newBackgroundContext()
        context.perform {
            do {
                try self.seedAll(in: context)
                try context.save()
                UserDefaults.standard.set(true, forKey: Self.seedVersionKey)
                completion(.success(()))
            } catch {
                print("[DataSeeder] Seeding failed: \(error)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - Internal Seeding Pipeline

    private func seedAll(in context: NSManagedObjectContext) throws {
        // 1. Seed national dex
        if let url = Bundle.main.url(forResource: "national_dex", withExtension: "json") {
            try seedPokemon(from: url, in: context)
        }

        // 2. Seed evolutions
        if let url = Bundle.main.url(forResource: "evolutions", withExtension: "json") {
            try seedEvolutions(from: url, in: context)
        }

        // 3. Seed all game bundles
        //    Each game is a directory named by game ID containing game.json + guide files
        if let gamesURL = Bundle.main.url(forResource: "Games", withExtension: nil) {
            let gameDirectories = try FileManager.default.contentsOfDirectory(
                at: gamesURL, includingPropertiesForKeys: nil
            )
            for dir in gameDirectories where dir.hasDirectoryPath {
                let gameId = dir.lastPathComponent
                if let gameURL = dir.appendingPathComponent("game.json") as URL?,
                   FileManager.default.fileExists(atPath: gameURL.path) {
                    try seedGame(from: gameURL, in: context)
                    try seedGuide(gameId: gameId, from: dir, in: context)
                }
            }
        }
    }

    // MARK: - Pokemon Seeding

    func seedPokemon(from url: URL, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let entries = try JSONDecoder().decode([PokemonJSON].self, from: data)

        for entry in entries {
            let pokemon = CDPokemon(context: context)
            pokemon.dexNumber = Int32(entry.dexNumber)
            pokemon.name = entry.name
            pokemon.types = entry.types
            pokemon.hp = Int16(entry.stats.hp)
            pokemon.attack = Int16(entry.stats.attack)
            pokemon.defense = Int16(entry.stats.defense)
            pokemon.spAttack = Int16(entry.stats.spAttack)
            pokemon.spDefense = Int16(entry.stats.spDefense)
            pokemon.speed = Int16(entry.stats.speed)
            pokemon.generation = Int16(entry.generation)
        }
    }

    // MARK: - Evolution Seeding

    func seedEvolutions(from url: URL, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let chains = try JSONDecoder().decode([EvolutionChainJSON].self, from: data)

        // Build a dexNumber -> CDPokemon lookup for linking relationships
        let pokemonLookup = try buildPokemonLookup(in: context)

        for chain in chains {
            for stage in chain.stages {
                let link = CDEvolutionLink(context: context)
                link.fromDexNumber = Int32(stage.fromDexNumber)
                link.toDexNumber = Int32(stage.toDexNumber)
                link.method = stage.method
                link.detail = stage.detail
                link.fromPokemon = pokemonLookup[Int32(stage.fromDexNumber)]
                link.toPokemon = pokemonLookup[Int32(stage.toDexNumber)]
            }
        }
    }

    // MARK: - Game Seeding

    func seedGame(from url: URL, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let gameJSON = try JSONDecoder().decode(GameJSON.self, from: data)

        let game = CDGame(context: context)
        game.id = gameJSON.id
        game.name = gameJSON.name
        game.generation = Int16(gameJSON.generation)
        game.region = gameJSON.region
        game.releaseYear = Int16(gameJSON.releaseYear)
        game.platform = gameJSON.platform
        game.accentColorHex = gameJSON.accentColorHex
        game.secondaryColorHex = gameJSON.secondaryColorHex
        game.iconName = gameJSON.iconName
        game.starterDexNumbers = gameJSON.starterDexNumbers
        game.gymCount = Int16(gameJSON.gymCount)
        game.hasEliteFour = gameJSON.hasEliteFour
        game.hasChampion = gameJSON.hasChampion

        // Seed regional dex entries
        let pokemonLookup = try buildPokemonLookup(in: context)

        for entry in gameJSON.regionalDex {
            let regional = CDRegionalDexEntry(context: context)
            regional.regionalDexNumber = Int32(entry.regionalDexNumber)
            regional.location = entry.location
            regional.game = game
            regional.pokemon = pokemonLookup[Int32(entry.nationalDexNumber)]
        }

        // Seed version exclusives as regional dex entries with availability
        if let exclusives = gameJSON.versionExclusives {
            for exclusive in exclusives {
                let regional = CDRegionalDexEntry(context: context)
                regional.regionalDexNumber = Int32(exclusive.regionalDexNumber)
                regional.location = exclusive.location
                regional.availability = exclusive.availability
                regional.game = game
                regional.pokemon = pokemonLookup[Int32(exclusive.nationalDexNumber)]
            }
        }
    }

    // MARK: - Guide Seeding

    func seedGuide(gameId: String, from directory: URL, in context: NSManagedObjectContext) throws {
        guard let game = try fetchGame(id: gameId, in: context) else {
            print("[DataSeeder] Game '\(gameId)' not found, skipping guide seeding")
            return
        }

        // Route
        let routeURL = directory.appendingPathComponent("route.json")
        if FileManager.default.fileExists(atPath: routeURL.path) {
            try seedRoute(from: routeURL, game: game, in: context)
        }

        // Gyms
        let gymsURL = directory.appendingPathComponent("gyms.json")
        if FileManager.default.fileExists(atPath: gymsURL.path) {
            try seedGyms(from: gymsURL, game: game, in: context)
        }

        // Team
        let teamURL = directory.appendingPathComponent("team.json")
        if FileManager.default.fileExists(atPath: teamURL.path) {
            try seedTeam(from: teamURL, game: game, in: context)
        }

        // Rival
        let rivalURL = directory.appendingPathComponent("rival.json")
        if FileManager.default.fileExists(atPath: rivalURL.path) {
            try seedRival(from: rivalURL, game: game, in: context)
        }

        // Elite Four
        let eliteFourURL = directory.appendingPathComponent("elite_four.json")
        if FileManager.default.fileExists(atPath: eliteFourURL.path) {
            try seedEliteFour(from: eliteFourURL, game: game, in: context)
        }

        // Tips
        let tipsURL = directory.appendingPathComponent("tips.json")
        if FileManager.default.fileExists(atPath: tipsURL.path) {
            try seedTips(from: tipsURL, game: game, in: context)
        }

        // Captures
        let capturesURL = directory.appendingPathComponent("captures.json")
        if FileManager.default.fileExists(atPath: capturesURL.path) {
            try seedCaptures(from: capturesURL, game: game, in: context)
        }

        // HMs & TMs
        let hmtmURL = directory.appendingPathComponent("hmtm.json")
        if FileManager.default.fileExists(atPath: hmtmURL.path) {
            try seedHMTM(from: hmtmURL, game: game, in: context)
        }

        // Pre-League
        let preLeagueURL = directory.appendingPathComponent("pre_league.json")
        if FileManager.default.fileExists(atPath: preLeagueURL.path) {
            try seedPreLeague(from: preLeagueURL, game: game, in: context)
        }

        // Postgame
        let postgameURL = directory.appendingPathComponent("postgame.json")
        if FileManager.default.fileExists(atPath: postgameURL.path) {
            try seedPostgame(from: postgameURL, game: game, in: context)
        }
    }

    // MARK: - Individual Guide Seeders

    private func seedRoute(from url: URL, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let route = try JSONDecoder().decode(GuideRouteJSON.self, from: data)

        for (sectionIndex, sectionJSON) in route.sections.enumerated() {
            let section = CDRouteSection(context: context)
            section.orderIndex = Int16(sectionIndex)
            section.title = sectionJSON.title
            section.game = game

            for (stepIndex, stepJSON) in sectionJSON.steps.enumerated() {
                let step = CDRouteStep(context: context)
                step.stepId = stepJSON.stepId
                step.text = stepJSON.text
                step.orderIndex = Int16(stepIndex)
                step.section = section
            }
        }
    }

    private func seedGyms(from url: URL, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let gyms = try JSONDecoder().decode([GuideGymJSON].self, from: data)

        for (index, gymJSON) in gyms.enumerated() {
            let gym = CDGym(context: context)
            gym.orderIndex = Int16(index)
            gym.name = gymJSON.name
            gym.leader = gymJSON.leader
            gym.levelRange = gymJSON.levelRange
            gym.note = gymJSON.note
            gym.badge = gymJSON.badge
            gym.game = game
        }
    }

    private func seedTeam(from url: URL, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let teamJSON = try JSONDecoder().decode(GuideTeamJSON.self, from: data)

        for recJSON in teamJSON.recommendations {
            let rec = CDTeamRecommendation(context: context)
            rec.starterCondition = recJSON.starterCondition
            rec.game = game

            for (memberIndex, memberJSON) in recJSON.members.enumerated() {
                let member = CDTeamMember(context: context)
                member.orderIndex = Int16(memberIndex)
                member.name = memberJSON.name
                member.moves = memberJSON.moves
                member.notes = memberJSON.notes
                member.emoji = memberJSON.emoji
                member.recommendation = rec
            }
        }
    }

    private func seedRival(from url: URL, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let rivalJSON = try JSONDecoder().decode(GuideRivalJSON.self, from: data)

        for (encounterIndex, encounterJSON) in rivalJSON.encounters.enumerated() {
            let encounter = CDRivalEncounter(context: context)
            encounter.orderIndex = Int16(encounterIndex)
            encounter.location = encounterJSON.location
            encounter.iconName = encounterJSON.iconName
            encounter.game = game

            for pokemonJSON in encounterJSON.team {
                let rivalPokemon = CDRivalPokemon(context: context)
                rivalPokemon.name = pokemonJSON.name
                rivalPokemon.level = Int16(pokemonJSON.level)
                rivalPokemon.dexNumber = Int32(pokemonJSON.dexNumber)
                rivalPokemon.starterCondition = pokemonJSON.starterCondition
                rivalPokemon.encounter = encounter
            }
        }
    }

    private func seedEliteFour(from url: URL, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let eliteJSON = try JSONDecoder().decode(GuideEliteFourJSON.self, from: data)

        for (index, memberJSON) in eliteJSON.members.enumerated() {
            let member = CDEliteFourMember(context: context)
            member.orderIndex = Int16(index)
            member.name = memberJSON.name
            member.strategy = memberJSON.strategy
            member.levels = memberJSON.levels
            member.game = game
        }
    }

    private func seedTips(from url: URL, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let tips = try JSONDecoder().decode([GuideTipJSON].self, from: data)

        for (index, tipJSON) in tips.enumerated() {
            let tip = CDTip(context: context)
            tip.orderIndex = Int16(index)
            tip.pokemon = tipJSON.pokemon
            tip.rule = tipJSON.rule
            tip.game = game
        }
    }

    private func seedCaptures(from url: URL, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let captures = try JSONDecoder().decode([GuideCaptureJSON].self, from: data)

        for (index, captureJSON) in captures.enumerated() {
            let capture = CDKeyCapture(context: context)
            capture.orderIndex = Int16(index)
            capture.pokemon = captureJSON.pokemon
            capture.location = captureJSON.location
            capture.note = captureJSON.note
            capture.game = game
        }
    }

    private func seedHMTM(from url: URL, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let hmtm = try JSONDecoder().decode(GuideHMTMJSON.self, from: data)

        for (index, hmJSON) in hmtm.hmEntries.enumerated() {
            let hm = CDHMEntry(context: context)
            hm.orderIndex = Int16(index)
            hm.hm = hmJSON.hm
            hm.pokemon = hmJSON.pokemon
            hm.location = hmJSON.location
            hm.game = game
        }

        for (index, tmJSON) in hmtm.tmEntries.enumerated() {
            let tm = CDTMEntry(context: context)
            tm.orderIndex = Int16(index)
            tm.tm = tmJSON.tm
            tm.target = tmJSON.target
            tm.origin = tmJSON.origin
            tm.game = game
        }
    }

    private func seedPreLeague(from url: URL, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let preLeague = try JSONDecoder().decode(GuidePreLeagueJSON.self, from: data)

        for (index, stepJSON) in preLeague.steps.enumerated() {
            let step = CDPreLeagueStep(context: context)
            step.stepId = stepJSON.stepId
            step.text = stepJSON.text
            step.orderIndex = Int16(index)
            step.game = game
        }
    }

    private func seedPostgame(from url: URL, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let postgame = try JSONDecoder().decode(GuidePostgameJSON.self, from: data)

        for (index, stepJSON) in postgame.steps.enumerated() {
            let step = CDPostgameStep(context: context)
            step.stepId = stepJSON.stepId
            step.text = stepJSON.text
            step.orderIndex = Int16(index)
            step.game = game
        }
    }

    // MARK: - Helpers

    private func buildPokemonLookup(in context: NSManagedObjectContext) throws -> [Int32: CDPokemon] {
        let request = NSFetchRequest<CDPokemon>(entityName: "CDPokemon")
        let results = try context.fetch(request)
        return Dictionary(uniqueKeysWithValues: results.map { ($0.dexNumber, $0) })
    }

    private func fetchGame(id: String, in context: NSManagedObjectContext) throws -> CDGame? {
        let request = NSFetchRequest<CDGame>(entityName: "CDGame")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
