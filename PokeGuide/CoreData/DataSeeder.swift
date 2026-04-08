//
//  DataSeeder.swift
//  PokeGuide
//
//  Seeds Core Data from bundled JSON files on first launch.
//  All seeding runs on a background context for performance.
//

import CoreData
import Foundation
import os

final class DataSeeder {
    private static let seedVersionKey = "dataSeeded_v4"

    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    // MARK: - Public API

    /// Seeds all data synchronously on the viewContext. Safe to call from app init.
    func seedIfNeededSync() {
        guard !UserDefaults.standard.bool(forKey: Self.seedVersionKey) else {
            print("[DataSeeder] Already seeded v3, skipping")
            return
        }

        print("[DataSeeder] Starting seed v3...")
        let context = persistenceController.container.viewContext
        context.performAndWait {
            do {
                try seedAll(in: context)
                try context.save()
                UserDefaults.standard.set(true, forKey: Self.seedVersionKey)
                print("[DataSeeder] Seed v3 completed successfully")
            } catch {
                print("[DataSeeder] Seeding FAILED: \(error)")
            }
        }
    }

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
                AppLogger.dataSeeder.error("Seeding failed: \(error)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - Internal Seeding Pipeline

    private func seedAll(in context: NSManagedObjectContext) throws {
        // 0. Clear existing data to avoid duplicates on re-seed
        print("[DataSeeder] Clearing old data...")
        try clearAllData(in: context)

        // 1. Seed national dex (supports single file or split-by-generation files)
        if let url = Bundle.main.url(forResource: "national_dex", withExtension: "json") {
            print("[DataSeeder] Seeding national dex (combined)...")
            try seedPokemon(from: url, in: context)
        } else {
            let genFiles = ["national_dex_gen1-3", "national_dex_gen4-6", "national_dex_gen7-9"]
            for name in genFiles {
                if let url = Bundle.main.url(forResource: name, withExtension: "json") {
                    print("[DataSeeder] Seeding \(name)...")
                    try seedPokemon(from: url, in: context)
                }
            }
        }

        // 2. Seed evolutions
        if let url = Bundle.main.url(forResource: "evolutions", withExtension: "json") {
            print("[DataSeeder] Seeding evolutions...")
            try seedEvolutions(from: url, in: context)
        }

        // 3. Seed all game bundles
        //    Game files follow the flat naming convention: {gameId}-game.json
        //    Guide files: {gameId}-route.json, {gameId}-gyms.json, etc.
        let filePrefixes = discoverGameIds()
        print("[DataSeeder] Discovered games: \(filePrefixes)")
        for filePrefix in filePrefixes {
            guard let gameURL = Bundle.main.url(forResource: "\(filePrefix)-game", withExtension: "json") else {
                print("[DataSeeder] No game.json for \(filePrefix), skipping")
                continue
            }
            // Read the actual game ID from the JSON (may differ from filename)
            let gameData = try Data(contentsOf: gameURL)
            let gameJSON = try JSONDecoder().decode(GameJSON.self, from: gameData)
            let gameId = gameJSON.id
            let guideBase = gameJSON.guideBase
            print("[DataSeeder] Seeding game \(gameId) (file: \(filePrefix), base: \(guideBase ?? "none"))...")
            try seedGame(from: gameURL, in: context)
            try seedGuideFlat(gameId: gameId, filePrefix: filePrefix, guideBase: guideBase, in: context)
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

        // Stages are sequential: [base, stage1, stage2, ...]
        // Create links from consecutive pairs
        for chain in chains {
            let stages = chain.stages
            for i in 1..<stages.count {
                let from = stages[i - 1]
                let to = stages[i]
                let link = CDEvolutionLink(context: context)
                link.fromDexNumber = Int32(from.dexNumber)
                link.toDexNumber = Int32(to.dexNumber)
                link.method = to.method ?? ""
                link.detail = to.detail ?? ""
                link.fromPokemon = pokemonLookup[Int32(from.dexNumber)]
                link.toPokemon = pokemonLookup[Int32(to.dexNumber)]
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

    // MARK: - Game Discovery

    /// Discovers game IDs by scanning the bundle for files matching `{gameId}-game.json`.
    private func discoverGameIds() -> [String] {
        guard let resourcePath = Bundle.main.resourcePath else { return [] }
        let allFiles = (try? FileManager.default.contentsOfDirectory(atPath: resourcePath)) ?? []
        return allFiles
            .filter { $0.hasSuffix("-game.json") }
            .map { $0.replacingOccurrences(of: "-game.json", with: "") }
            .sorted()
    }

    // MARK: - Guide Seeding (flat bundle layout)

    private func seedGuideFlat(gameId: String, filePrefix: String, guideBase: String?, in context: NSManagedObjectContext) throws {
        guard let game = try fetchGame(id: gameId, in: context) else {
            print("[DataSeeder] Game '\(gameId)' not found in Core Data, skipping guide")
            return
        }

        // Resolve a guide resource URL: try game-specific file first, then guideBase fallback
        func resolve(_ suffix: String) -> URL? {
            if let url = Bundle.main.url(forResource: "\(filePrefix)-\(suffix)", withExtension: "json") {
                return url
            }
            if let base = guideBase,
               let url = Bundle.main.url(forResource: "\(base)-\(suffix)", withExtension: "json") {
                return url
            }
            return nil
        }

        // Route
        if let url = resolve("route") {
            try seedRoute(from: url, game: game, in: context)
        }

        // Gyms
        if let url = resolve("gyms") {
            try seedGyms(from: url, game: game, in: context)
        }

        // Team (one file per starter: {gameId}-team-squirtle.json, etc.)
        if let resourcePath = Bundle.main.resourcePath {
            var teamPrefix = "\(filePrefix)-team-"
            let allFiles = (try? FileManager.default.contentsOfDirectory(atPath: resourcePath)) ?? []
            var teamFiles = allFiles.filter { $0.hasPrefix(teamPrefix) && $0.hasSuffix(".json") }

            // Fallback to base game's team files
            if teamFiles.isEmpty, let base = guideBase {
                teamPrefix = "\(base)-team-"
                teamFiles = allFiles.filter { $0.hasPrefix(teamPrefix) && $0.hasSuffix(".json") }
            }

            for fileName in teamFiles {
                let starter = fileName.replacingOccurrences(of: teamPrefix, with: "").replacingOccurrences(of: ".json", with: "")
                let url = URL(fileURLWithPath: resourcePath).appendingPathComponent(fileName)
                try seedTeam(from: url, starter: starter, game: game, in: context)
            }
        }

        // Elite Four
        if let url = resolve("elite-four") {
            try seedEliteFour(from: url, game: game, in: context)
        }

        // Tips
        if let url = resolve("tips") {
            try seedTips(from: url, game: game, in: context)
        }

        // Captures
        if let url = resolve("captures") {
            try seedCaptures(from: url, game: game, in: context)
        }

        // HMs & TMs
        if let url = resolve("hm-tm") {
            try seedHMTM(from: url, game: game, in: context)
        }

        // Pre-League
        if let url = resolve("pre_league") {
            try seedPreLeague(from: url, game: game, in: context)
        }

        // Postgame
        if let url = resolve("postgame") {
            try seedPostgame(from: url, game: game, in: context)
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
        let wrapper = try JSONDecoder().decode(GuideGymsJSON.self, from: data)

        for (index, gymJSON) in wrapper.gyms.enumerated() {
            let gym = CDGym(context: context)
            gym.orderIndex = Int16(index)
            gym.name = gymJSON.name
            gym.leader = gymJSON.leader
            gym.levelRange = gymJSON.levelRange
            gym.note = gymJSON.note
            gym.badge = gymJSON.badge
            gym.badgeSpriteId = Int16(gymJSON.badgeSpriteId ?? 0)
            gym.game = game
        }
    }

    private func seedTeam(from url: URL, starter: String, game: CDGame, in context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let teamJSON = try JSONDecoder().decode(GuideTeamMembersJSON.self, from: data)

        let rec = CDTeamRecommendation(context: context)
        rec.starterCondition = starter
        rec.game = game

        for (memberIndex, memberJSON) in teamJSON.members.enumerated() {
            let member = CDTeamMember(context: context)
            member.orderIndex = Int16(memberIndex)
            member.name = memberJSON.name
            let resolvedDex = PokedexData.kanto.first { $0.name == memberJSON.name }?.id ?? 0
            member.dexNumber = Int32(resolvedDex)
            if resolvedDex == 0 {
                print("[DataSeeder] WARNING: Could not resolve dexNumber for team member '\(memberJSON.name)'")
            }
            member.moves = memberJSON.moves
            member.notes = memberJSON.notes
            member.emoji = memberJSON.emoji
            member.recommendation = rec
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

    // MARK: - Data Cleanup

    private func clearAllData(in context: NSManagedObjectContext) throws {
        let entityNames = [
            "CDRouteStep", "CDRouteSection",
            "CDGym", "CDEliteFourMember", "CDTip", "CDKeyCapture",
            "CDHMEntry", "CDTMEntry", "CDTeamMember", "CDTeamRecommendation",
            "CDPreLeagueStep", "CDPostgameStep",
            "CDRegionalDexEntry", "CDEvolutionLink",
            "CDGame", "CDPokemon",
        ]
        for name in entityNames {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteRequest)
        }
        context.reset()
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
