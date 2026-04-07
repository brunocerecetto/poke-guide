//
//  PokemonLoader.swift
//  PokeGuide
//
//  Loads Pokémon from bundled national dex JSON files and converts
//  them to PokemonEntry objects for use in the Pokédex views.
//

import Foundation

enum PokemonLoader {
    /// All Pokémon loaded from the three national_dex JSON files, cached after first access.
    nonisolated(unsafe) private static var _cache: [PokemonEntry]?

    static var allEntries: [PokemonEntry] {
        if let cached = _cache { return cached }
        let entries = loadFromBundle()
        _cache = entries
        return entries
    }

    /// Returns Pokémon entries for a specific game, filtered by its max national dex number.
    /// For Gen 1 Kanto games, returns the rich hardcoded data from PokedexData.kanto.
    static func entries(for game: GameCatalogEntry) -> [PokemonEntry] {
        if game.generation == 1 {
            return PokedexData.kanto
        }
        let loaded = allEntries.filter { $0.id <= game.nationalDexMax }
        return loaded.isEmpty ? PokedexData.kanto : loaded
    }

    /// Returns Pokémon entries for a game ID string.
    static func entries(forGameId gameId: String) -> [PokemonEntry] {
        guard let game = GameCatalogEntry.allGames.first(where: { $0.id == gameId }) else {
            return PokedexData.kanto
        }
        return entries(for: game)
    }

    // MARK: - Private

    private static func loadFromBundle() -> [PokemonEntry] {
        let fileNames = [
            "national_dex_gen1-3",
        ]
        let decoder = JSONDecoder()
        var entries: [PokemonEntry] = []

        for fileName in fileNames {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let decoded = try? decoder.decode([NationalDexJSON].self, from: data) else {
                continue
            }
            entries.append(contentsOf: decoded.map { $0.toPokemonEntry() })
        }
        return entries
    }
}

// MARK: - JSON Model

private struct NationalDexJSON: Decodable {
    let dexNumber: Int
    let name: String
    let types: [String]
    let stats: StatsJSON
    let generation: Int

    struct StatsJSON: Decodable {
        let hp: Int
        let attack: Int
        let defense: Int
        let spAttack: Int
        let spDefense: Int
        let speed: Int
    }

    func toPokemonEntry() -> PokemonEntry {
        PokemonEntry(
            id: dexNumber,
            name: name,
            types: types.compactMap { PokemonType(rawValue: $0) },
            stats: PokemonStats(
                hp: stats.hp,
                attack: stats.attack,
                defense: stats.defense,
                spAttack: stats.spAttack,
                spDefense: stats.spDefense,
                speed: stats.speed
            ),
            location: "",
            description: ""
        )
    }
}
