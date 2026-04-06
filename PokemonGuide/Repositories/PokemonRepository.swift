//
//  PokemonRepository.swift
//  PokemonGuide
//
//  Repository layer for querying Pokemon data from Core Data.
//  Returns lightweight DTO structs decoupled from NSManagedObject.
//

import Foundation
import CoreData
import Combine

// MARK: - DTOs

struct PokemonDTO: Identifiable, Equatable {
    let id: Int
    let name: String
    let types: [String]
    let hp: Int
    let attack: Int
    let defense: Int
    let spAttack: Int
    let spDefense: Int
    let speed: Int
    let generation: Int

    var total: Int { hp + attack + defense + spAttack + spDefense + speed }

    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }
}

struct RegionalDexEntryDTO: Identifiable, Equatable {
    let id: Int
    let nationalDex: Int
    let name: String
    let types: [String]
    let location: String
    let availability: String?
    let hp: Int
    let attack: Int
    let defense: Int
    let spAttack: Int
    let spDefense: Int
    let speed: Int

    var total: Int { hp + attack + defense + spAttack + spDefense + speed }

    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(nationalDex).png")
    }
}

struct EvolutionLinkDTO: Identifiable, Equatable {
    let id: String
    let fromDex: Int
    let fromName: String
    let toDex: Int
    let toName: String
    let method: String
    let detail: String
}

// MARK: - Repository

class PokemonRepository: ObservableObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - All Pokemon (national dex order)

    func allPokemon() -> [PokemonDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Pokemon")
        request.sortDescriptors = [NSSortDescriptor(key: "dexNumber", ascending: true)]

        guard let results = try? context.fetch(request) else { return [] }
        return results.compactMap { mapToPokemonDTO($0) }
    }

    // MARK: - Single Pokemon by dex number

    func pokemon(dex: Int) -> PokemonDTO? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Pokemon")
        request.predicate = NSPredicate(format: "dexNumber == %d", dex)
        request.fetchLimit = 1

        guard let result = try? context.fetch(request).first else { return nil }
        return mapToPokemonDTO(result)
    }

    // MARK: - Regional dex for a specific game

    func regionalDex(gameId: String) -> [RegionalDexEntryDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "RegionalDexEntry")
        request.predicate = NSPredicate(format: "game.id == %@", gameId)
        request.sortDescriptors = [NSSortDescriptor(key: "regionalNumber", ascending: true)]

        guard let results = try? context.fetch(request) else { return [] }
        return results.compactMap { mapToRegionalDexEntryDTO($0) }
    }

    // MARK: - Search by name

    func search(query: String) -> [PokemonDTO] {
        guard !query.isEmpty else { return allPokemon() }

        let request = NSFetchRequest<NSManagedObject>(entityName: "Pokemon")
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        request.sortDescriptors = [NSSortDescriptor(key: "dexNumber", ascending: true)]

        guard let results = try? context.fetch(request) else { return [] }
        return results.compactMap { mapToPokemonDTO($0) }
    }

    // MARK: - Pokemon by type

    func pokemon(ofType type: String) -> [PokemonDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Pokemon")
        request.predicate = NSPredicate(format: "typesJSON CONTAINS[cd] %@", type)
        request.sortDescriptors = [NSSortDescriptor(key: "dexNumber", ascending: true)]

        guard let results = try? context.fetch(request) else { return [] }
        return results.compactMap { mapToPokemonDTO($0) }
    }

    // MARK: - Pokemon by generation

    func pokemon(generation: Int) -> [PokemonDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Pokemon")
        request.predicate = NSPredicate(format: "generation == %d", generation)
        request.sortDescriptors = [NSSortDescriptor(key: "dexNumber", ascending: true)]

        guard let results = try? context.fetch(request) else { return [] }
        return results.compactMap { mapToPokemonDTO($0) }
    }

    // MARK: - Evolution chain for a single Pokemon

    func evolutionChain(forDex dex: Int) -> [EvolutionLinkDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "EvolutionLink")
        request.predicate = NSPredicate(
            format: "fromDex == %d OR toDex == %d", dex, dex
        )
        request.sortDescriptors = [NSSortDescriptor(key: "fromDex", ascending: true)]

        guard let results = try? context.fetch(request) else { return [] }

        // Collect all linked dex numbers to build the full chain
        var chainDexNumbers = Set<Int>()
        for link in results {
            chainDexNumbers.insert(link.value(forKey: "fromDex") as? Int ?? 0)
            chainDexNumbers.insert(link.value(forKey: "toDex") as? Int ?? 0)
        }

        // Re-fetch all links involving any member of the chain
        let expandedRequest = NSFetchRequest<NSManagedObject>(entityName: "EvolutionLink")
        let predicates = chainDexNumbers.flatMap { num in
            [
                NSPredicate(format: "fromDex == %d", num),
                NSPredicate(format: "toDex == %d", num),
            ]
        }
        expandedRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        expandedRequest.sortDescriptors = [
            NSSortDescriptor(key: "fromDex", ascending: true),
            NSSortDescriptor(key: "toDex", ascending: true),
        ]

        guard let expanded = try? context.fetch(expandedRequest) else {
            return results.compactMap { mapToEvolutionLinkDTO($0) }
        }
        return expanded.compactMap { mapToEvolutionLinkDTO($0) }
    }

    // MARK: - All evolution chains (grouped)

    func allEvolutionChains() -> [[EvolutionLinkDTO]] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "EvolutionLink")
        request.sortDescriptors = [
            NSSortDescriptor(key: "fromDex", ascending: true),
            NSSortDescriptor(key: "toDex", ascending: true),
        ]

        guard let results = try? context.fetch(request) else { return [] }
        let allLinks = results.compactMap { mapToEvolutionLinkDTO($0) }

        // Group links into chains using union-find on dex numbers
        var parent: [Int: Int] = [:]

        func find(_ x: Int) -> Int {
            if parent[x] == nil { parent[x] = x }
            if parent[x] != x { parent[x] = find(parent[x]!) }
            return parent[x]!
        }

        func union(_ a: Int, _ b: Int) {
            let ra = find(a), rb = find(b)
            if ra != rb { parent[ra] = rb }
        }

        for link in allLinks {
            union(link.fromDex, link.toDex)
        }

        var chains: [Int: [EvolutionLinkDTO]] = [:]
        for link in allLinks {
            let root = find(link.fromDex)
            chains[root, default: []].append(link)
        }

        return chains.values
            .sorted { ($0.first?.fromDex ?? 0) < ($1.first?.fromDex ?? 0) }
    }

    // MARK: - Version availability check

    func isAvailable(dex: Int, inGame gameId: String) -> Bool {
        let request = NSFetchRequest<NSManagedObject>(entityName: "RegionalDexEntry")
        request.predicate = NSPredicate(
            format: "pokemon.dexNumber == %d AND game.id == %@", dex, gameId
        )
        request.fetchLimit = 1

        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }

    // MARK: - Mapping helpers

    private func mapToPokemonDTO(_ object: NSManagedObject) -> PokemonDTO? {
        guard let name = object.value(forKey: "name") as? String,
              let dex = object.value(forKey: "dexNumber") as? Int
        else { return nil }

        let types = decodeJSONStringArray(object.value(forKey: "typesJSON") as? Data)

        return PokemonDTO(
            id: dex,
            name: name,
            types: types,
            hp: object.value(forKey: "hp") as? Int ?? 0,
            attack: object.value(forKey: "attack") as? Int ?? 0,
            defense: object.value(forKey: "defense") as? Int ?? 0,
            spAttack: object.value(forKey: "spAttack") as? Int ?? 0,
            spDefense: object.value(forKey: "spDefense") as? Int ?? 0,
            speed: object.value(forKey: "speed") as? Int ?? 0,
            generation: object.value(forKey: "generation") as? Int ?? 1
        )
    }

    private func mapToRegionalDexEntryDTO(_ object: NSManagedObject) -> RegionalDexEntryDTO? {
        guard let regionalNumber = object.value(forKey: "regionalNumber") as? Int else {
            return nil
        }

        let pokemon = object.value(forKey: "pokemon") as? NSManagedObject
        let name = pokemon?.value(forKey: "name") as? String ?? ""
        let nationalDex = pokemon?.value(forKey: "dexNumber") as? Int ?? 0
        let types = decodeJSONStringArray(pokemon?.value(forKey: "typesJSON") as? Data)

        return RegionalDexEntryDTO(
            id: regionalNumber,
            nationalDex: nationalDex,
            name: name,
            types: types,
            location: object.value(forKey: "location") as? String ?? "",
            availability: object.value(forKey: "availability") as? String,
            hp: pokemon?.value(forKey: "hp") as? Int ?? 0,
            attack: pokemon?.value(forKey: "attack") as? Int ?? 0,
            defense: pokemon?.value(forKey: "defense") as? Int ?? 0,
            spAttack: pokemon?.value(forKey: "spAttack") as? Int ?? 0,
            spDefense: pokemon?.value(forKey: "spDefense") as? Int ?? 0,
            speed: pokemon?.value(forKey: "speed") as? Int ?? 0
        )
    }

    private func mapToEvolutionLinkDTO(_ object: NSManagedObject) -> EvolutionLinkDTO? {
        guard let fromDex = object.value(forKey: "fromDex") as? Int,
              let toDex = object.value(forKey: "toDex") as? Int
        else { return nil }

        return EvolutionLinkDTO(
            id: "\(fromDex)-\(toDex)",
            fromDex: fromDex,
            fromName: object.value(forKey: "fromName") as? String ?? "",
            toDex: toDex,
            toName: object.value(forKey: "toName") as? String ?? "",
            method: object.value(forKey: "method") as? String ?? "",
            detail: object.value(forKey: "detail") as? String ?? ""
        )
    }

    // MARK: - JSON decoding

    private func decodeJSONStringArray(_ data: Data?) -> [String] {
        guard let data else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}
