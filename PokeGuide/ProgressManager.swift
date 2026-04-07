//
//  ProgressManager.swift
//  poke guide
//
//  Persiste todo el progreso offline usando UserDefaults.
//  Las keys están namespaceadas por GameVersion + Starter.
//
//  NOTE: ProgressRepository (Core Data) coexists for future CloudKit sync.
//  ProgressManager remains the active source of truth for UserDefaults-based progress.
//

import Foundation
import Combine

@MainActor
class ProgressManager: ObservableObject {
    private let defaults = UserDefaults.standard
    private var prefix: String

    private var gymKey: String { "\(prefix)_completedGyms" }
    private var routeKey: String { "\(prefix)_completedRouteSteps" }
    private var leagueKey: String { "\(prefix)_completedLeague" }
    private var preLeagueKey: String { "\(prefix)_completedPreLeague" }
    private var postgameKey: String { "\(prefix)_completedPostgame" }
    private var pokedexKey: String { "\(prefix)_pokemonStatuses" }
    private var customTeamKey: String { "\(prefix)_customTeam" }

    @Published var completedGyms: Set<String> {
        didSet { save(completedGyms, forKey: gymKey) }
    }
    @Published var completedRouteSteps: Set<String> {
        didSet { save(completedRouteSteps, forKey: routeKey) }
    }
    @Published var completedLeague: Set<String> {
        didSet { save(completedLeague, forKey: leagueKey) }
    }
    @Published var completedPreLeague: Set<String> {
        didSet { save(completedPreLeague, forKey: preLeagueKey) }
    }
    @Published var completedPostgame: Set<String> {
        didSet { save(completedPostgame, forKey: postgameKey) }
    }

    @Published var pokemonStatuses: [Int: PokemonStatus] {
        didSet { savePokedex() }
    }

    @Published var customTeamDexNumbers: [Int] {
        didSet { defaults.set(customTeamDexNumbers, forKey: customTeamKey) }
    }

    init(prefix: String = "fireRed_squirtle") {
        self.prefix = prefix

        let gymK = "\(prefix)_completedGyms"
        let routeK = "\(prefix)_completedRouteSteps"
        let leagueK = "\(prefix)_completedLeague"
        let preLeagueK = "\(prefix)_completedPreLeague"
        let postgameK = "\(prefix)_completedPostgame"
        let pokedexK = "\(prefix)_pokemonStatuses"

        // Migrate legacy unnamespaced keys if namespaced keys don't exist yet
        if prefix == "fireRed_squirtle" {
            Self.migrateIfNeeded(from: "completedGyms", to: gymK)
            Self.migrateIfNeeded(from: "completedRouteSteps", to: routeK)
            Self.migrateIfNeeded(from: "completedLeague", to: leagueK)
            Self.migrateIfNeeded(from: "completedPreLeague", to: preLeagueK)
            Self.migrateIfNeeded(from: "completedPostgame", to: postgameK)
            Self.migrateIfNeeded(from: "pokemonStatuses", to: pokedexK)
        }

        _completedGyms = Published(initialValue: Self.load(forKey: gymK))
        _completedRouteSteps = Published(initialValue: Self.load(forKey: routeK))
        _completedLeague = Published(initialValue: Self.load(forKey: leagueK))
        _completedPreLeague = Published(initialValue: Self.load(forKey: preLeagueK))
        _completedPostgame = Published(initialValue: Self.load(forKey: postgameK))
        _pokemonStatuses = Published(initialValue: Self.loadPokedex(forKey: pokedexK))

        let teamK = "\(prefix)_customTeam"
        _customTeamDexNumbers = Published(initialValue: UserDefaults.standard.array(forKey: teamK) as? [Int] ?? [])
    }

    /// Reload progress for a different game config
    func switchConfig(prefix newPrefix: String) {
        prefix = newPrefix
        completedGyms = Self.load(forKey: gymKey)
        completedRouteSteps = Self.load(forKey: routeKey)
        completedLeague = Self.load(forKey: leagueKey)
        completedPreLeague = Self.load(forKey: preLeagueKey)
        completedPostgame = Self.load(forKey: postgameKey)
        pokemonStatuses = Self.loadPokedex(forKey: pokedexKey)
        customTeamDexNumbers = UserDefaults.standard.array(forKey: customTeamKey) as? [Int] ?? []
    }

    // MARK: - Gym toggles

    func isGymCompleted(_ name: String) -> Bool {
        completedGyms.contains(name)
    }

    func toggleGym(_ name: String) {
        if completedGyms.contains(name) {
            completedGyms.remove(name)
        } else {
            completedGyms.insert(name)
        }
    }

    // MARK: - Route step toggles

    func isRouteStepCompleted(_ id: String) -> Bool {
        completedRouteSteps.contains(id)
    }

    func toggleRouteStep(_ id: String) {
        if completedRouteSteps.contains(id) {
            completedRouteSteps.remove(id)
        } else {
            completedRouteSteps.insert(id)
        }
    }

    // MARK: - League toggles

    func isLeagueCompleted(_ name: String) -> Bool {
        completedLeague.contains(name)
    }

    func toggleLeague(_ name: String) {
        if completedLeague.contains(name) {
            completedLeague.remove(name)
        } else {
            completedLeague.insert(name)
        }
    }

    // MARK: - Pre-league checklist

    func isPreLeagueCompleted(_ id: String) -> Bool {
        completedPreLeague.contains(id)
    }

    func togglePreLeague(_ id: String) {
        if completedPreLeague.contains(id) {
            completedPreLeague.remove(id)
        } else {
            completedPreLeague.insert(id)
        }
    }

    // MARK: - Postgame

    func isPostgameCompleted(_ id: String) -> Bool {
        completedPostgame.contains(id)
    }

    func togglePostgame(_ id: String) {
        if completedPostgame.contains(id) {
            completedPostgame.remove(id)
        } else {
            completedPostgame.insert(id)
        }
    }

    // MARK: - Pokédex

    func pokemonStatus(for dexNumber: Int) -> PokemonStatus {
        pokemonStatuses[dexNumber] ?? .notSeen
    }

    func cyclePokemonStatus(for dexNumber: Int) {
        let current = pokemonStatus(for: dexNumber)
        pokemonStatuses[dexNumber] = current.next
    }

    func setPokemonStatus(for dexNumber: Int, to status: PokemonStatus) {
        pokemonStatuses[dexNumber] = status
    }

    // MARK: - Custom Team

    func setCustomTeamSlot(_ slot: Int, dexNumber: Int?) {
        var team = customTeamDexNumbers
        // Ensure array has 6 slots
        while team.count < 6 { team.append(0) }
        guard slot >= 0 && slot < 6 else { return }
        team[slot] = dexNumber ?? 0
        customTeamDexNumbers = team
    }

    func customTeamEntries(gameId: String) -> [PokemonEntry?] {
        let all = PokemonLoader.entries(forGameId: gameId)
        var team = customTeamDexNumbers
        while team.count < 6 { team.append(0) }
        return team.prefix(6).map { dex in
            dex > 0 ? all.first(where: { $0.id == dex }) : nil
        }
    }

    // MARK: - Overall progress

    /// Total checkable items. Use `totalCheckable(from:)` with a bridge for accurate counts.
    /// Falls back to legacy GameData when no bridge is available.
    var totalCheckable: Int {
        GameData.gyms.count
        + GameData.routeSections.flatMap(\.steps).count
        + GameData.eliteFour.count
        + GameData.preLeagueChecklist.count
        + GameData.postgame.count
    }

    func totalCheckable(from bridge: GameDataBridge) -> Int {
        bridge.totalCheckable
    }

    var totalCompleted: Int {
        completedGyms.count
        + completedRouteSteps.count
        + completedLeague.count
        + completedPreLeague.count
        + completedPostgame.count
    }

    var progressFraction: Double {
        guard totalCheckable > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalCheckable)
    }

    // MARK: - Reset

    func resetAll() {
        completedGyms.removeAll()
        completedRouteSteps.removeAll()
        completedLeague.removeAll()
        completedPreLeague.removeAll()
        completedPostgame.removeAll()
        pokemonStatuses.removeAll()
        customTeamDexNumbers.removeAll()
    }

    // MARK: - Persistence helpers

    private func save(_ set: Set<String>, forKey key: String) {
        defaults.set(Array(set), forKey: key)
    }

    private static func load(forKey key: String) -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(array)
    }

    // MARK: - Pokédex persistence

    private func savePokedex() {
        let dict = pokemonStatuses.reduce(into: [String: Int]()) { result, pair in
            result[String(pair.key)] = pair.value.rawValue
        }
        defaults.set(dict, forKey: pokedexKey)
    }

    private static func loadPokedex(forKey key: String) -> [Int: PokemonStatus] {
        guard let dict = UserDefaults.standard.dictionary(forKey: key) as? [String: Int] else {
            return [:]
        }
        return dict.reduce(into: [Int: PokemonStatus]()) { result, pair in
            if let dexNum = Int(pair.key), let status = PokemonStatus(rawValue: pair.value) {
                result[dexNum] = status
            }
        }
    }

    // MARK: - Migration

    private static func migrateIfNeeded(from oldKey: String, to newKey: String) {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: newKey) == nil,
              let oldValue = defaults.object(forKey: oldKey) else { return }
        defaults.set(oldValue, forKey: newKey)
        defaults.removeObject(forKey: oldKey)
    }
}
