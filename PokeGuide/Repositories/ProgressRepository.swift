//
//  ProgressRepository.swift
//  PokeGuide
//
//  Core Data-backed replacement for the UserDefaults ProgressManager.
//  Maintains the same toggle/query API so existing views can migrate
//  with minimal changes. CloudKit sync is handled automatically by
//  NSPersistentCloudKitContainer.
//

import Foundation
import CoreData
import Combine

// MARK: - DTO

struct ProgressDTO: Equatable {
    var gameId: String
    var starterId: String
    var completedGyms: Set<String>
    var completedRouteSteps: Set<String>
    var completedLeague: Set<String>
    var completedPreLeague: Set<String>
    var completedPostgame: Set<String>
    var pokemonStatuses: [Int: Int] // dex -> raw status (0=notSeen, 1=seen, 2=caught, 3=evolved)

    static func empty(gameId: String, starterId: String) -> ProgressDTO {
        ProgressDTO(
            gameId: gameId,
            starterId: starterId,
            completedGyms: [],
            completedRouteSteps: [],
            completedLeague: [],
            completedPreLeague: [],
            completedPostgame: [],
            pokemonStatuses: [:]
        )
    }
}

// MARK: - Repository

class ProgressRepository: ObservableObject {
    private let context: NSManagedObjectContext
    private var managedProgress: NSManagedObject?

    @Published var currentProgress: ProgressDTO

    init(context: NSManagedObjectContext, gameId: String, starterId: String) {
        self.context = context
        self.currentProgress = .empty(gameId: gameId, starterId: starterId)
        loadProgress(gameId: gameId, starterId: starterId)
    }

    // MARK: - Load / create

    func loadProgress(gameId: String, starterId: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDProgress")
        request.predicate = NSPredicate(
            format: "gameId == %@ AND starterId == %@", gameId, starterId
        )
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            managedProgress = existing
            currentProgress = mapToDTO(existing)
        } else {
            guard let entity = NSEntityDescription.entity(forEntityName: "CDProgress", in: context) else {
                print("CDProgress entity not found")
                return
            }
            let newProgress = NSManagedObject(entity: entity, insertInto: context)
            newProgress.setValue(gameId, forKey: "gameId")
            newProgress.setValue(starterId, forKey: "starterId")
            newProgress.setValue(Data(), forKey: "completedGymsJSON")
            newProgress.setValue(Data(), forKey: "completedRouteStepsJSON")
            newProgress.setValue(Data(), forKey: "completedLeagueJSON")
            newProgress.setValue(Data(), forKey: "completedPreLeagueJSON")
            newProgress.setValue(Data(), forKey: "completedPostgameJSON")
            newProgress.setValue(Data(), forKey: "pokemonStatusesJSON")
            save()

            managedProgress = newProgress
            currentProgress = .empty(gameId: gameId, starterId: starterId)
        }
    }

    // MARK: - Gym toggles

    func isGymCompleted(_ name: String) -> Bool {
        currentProgress.completedGyms.contains(name)
    }

    func toggleGym(_ name: String) {
        if currentProgress.completedGyms.contains(name) {
            currentProgress.completedGyms.remove(name)
        } else {
            currentProgress.completedGyms.insert(name)
        }
        persist(\.completedGyms, key: "completedGymsJSON")
    }

    // MARK: - Route step toggles

    func isRouteStepCompleted(_ id: String) -> Bool {
        currentProgress.completedRouteSteps.contains(id)
    }

    func toggleRouteStep(_ id: String) {
        if currentProgress.completedRouteSteps.contains(id) {
            currentProgress.completedRouteSteps.remove(id)
        } else {
            currentProgress.completedRouteSteps.insert(id)
        }
        persist(\.completedRouteSteps, key: "completedRouteStepsJSON")
    }

    // MARK: - League toggles

    func isLeagueCompleted(_ name: String) -> Bool {
        currentProgress.completedLeague.contains(name)
    }

    func toggleLeague(_ name: String) {
        if currentProgress.completedLeague.contains(name) {
            currentProgress.completedLeague.remove(name)
        } else {
            currentProgress.completedLeague.insert(name)
        }
        persist(\.completedLeague, key: "completedLeagueJSON")
    }

    // MARK: - Pre-league

    func isPreLeagueCompleted(_ id: String) -> Bool {
        currentProgress.completedPreLeague.contains(id)
    }

    func togglePreLeague(_ id: String) {
        if currentProgress.completedPreLeague.contains(id) {
            currentProgress.completedPreLeague.remove(id)
        } else {
            currentProgress.completedPreLeague.insert(id)
        }
        persist(\.completedPreLeague, key: "completedPreLeagueJSON")
    }

    // MARK: - Postgame

    func isPostgameCompleted(_ id: String) -> Bool {
        currentProgress.completedPostgame.contains(id)
    }

    func togglePostgame(_ id: String) {
        if currentProgress.completedPostgame.contains(id) {
            currentProgress.completedPostgame.remove(id)
        } else {
            currentProgress.completedPostgame.insert(id)
        }
        persist(\.completedPostgame, key: "completedPostgameJSON")
    }

    // MARK: - Pokemon status

    func pokemonStatus(for dexNumber: Int) -> Int {
        currentProgress.pokemonStatuses[dexNumber] ?? 0
    }

    func cyclePokemonStatus(for dexNumber: Int) {
        let current = pokemonStatus(for: dexNumber)
        let next = (current + 1) % 4
        currentProgress.pokemonStatuses[dexNumber] = next == 0 ? nil : next
        persistPokemonStatuses()
    }

    // MARK: - Overall progress

    var totalCompleted: Int {
        currentProgress.completedGyms.count
        + currentProgress.completedRouteSteps.count
        + currentProgress.completedLeague.count
        + currentProgress.completedPreLeague.count
        + currentProgress.completedPostgame.count
    }

    func totalCheckable(guideRepo: GuideRepository) -> Int {
        let gameId = currentProgress.gameId
        let gyms = guideRepo.gyms(gameId: gameId).count
        let steps = guideRepo.routeSections(gameId: gameId).flatMap(\.steps).count
        let elite = guideRepo.eliteFour(gameId: gameId).count
        let pre = guideRepo.preLeagueChecklist(gameId: gameId).count
        let post = guideRepo.postgameChecklist(gameId: gameId).count
        return gyms + steps + elite + pre + post
    }

    func progressFraction(guideRepo: GuideRepository) -> Double {
        let total = totalCheckable(guideRepo: guideRepo)
        guard total > 0 else { return 0 }
        return Double(totalCompleted) / Double(total)
    }

    // MARK: - Reset

    func resetAll() {
        currentProgress.completedGyms.removeAll()
        currentProgress.completedRouteSteps.removeAll()
        currentProgress.completedLeague.removeAll()
        currentProgress.completedPreLeague.removeAll()
        currentProgress.completedPostgame.removeAll()
        currentProgress.pokemonStatuses.removeAll()

        managedProgress?.setValue(encodeStringSet([]), forKey: "completedGymsJSON")
        managedProgress?.setValue(encodeStringSet([]), forKey: "completedRouteStepsJSON")
        managedProgress?.setValue(encodeStringSet([]), forKey: "completedLeagueJSON")
        managedProgress?.setValue(encodeStringSet([]), forKey: "completedPreLeagueJSON")
        managedProgress?.setValue(encodeStringSet([]), forKey: "completedPostgameJSON")
        managedProgress?.setValue(encodeIntDict([:]), forKey: "pokemonStatusesJSON")
        save()
    }

    // MARK: - Save

    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("ProgressRepository save error: \(error.localizedDescription)")
        }
    }

    // MARK: - Private persistence

    private func persist(_ keyPath: KeyPath<ProgressDTO, Set<String>>, key: String) {
        let value = currentProgress[keyPath: keyPath]
        managedProgress?.setValue(encodeStringSet(value), forKey: key)
        save()
    }

    private func persistPokemonStatuses() {
        managedProgress?.setValue(
            encodeIntDict(currentProgress.pokemonStatuses),
            forKey: "pokemonStatusesJSON"
        )
        save()
    }

    // MARK: - DTO mapping

    private func mapToDTO(_ object: NSManagedObject) -> ProgressDTO {
        ProgressDTO(
            gameId: object.value(forKey: "gameId") as? String ?? "",
            starterId: object.value(forKey: "starterId") as? String ?? "",
            completedGyms: decodeStringSet(object.value(forKey: "completedGymsJSON") as? Data),
            completedRouteSteps: decodeStringSet(object.value(forKey: "completedRouteStepsJSON") as? Data),
            completedLeague: decodeStringSet(object.value(forKey: "completedLeagueJSON") as? Data),
            completedPreLeague: decodeStringSet(object.value(forKey: "completedPreLeagueJSON") as? Data),
            completedPostgame: decodeStringSet(object.value(forKey: "completedPostgameJSON") as? Data),
            pokemonStatuses: decodeIntDict(object.value(forKey: "pokemonStatusesJSON") as? Data)
        )
    }

    // MARK: - JSON encoding / decoding

    private func encodeStringSet(_ set: Set<String>) -> Data {
        (try? JSONEncoder().encode(Array(set))) ?? Data()
    }

    private func decodeStringSet(_ data: Data?) -> Set<String> {
        guard let data, !data.isEmpty else { return [] }
        guard let array = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return Set(array)
    }

    private func encodeIntDict(_ dict: [Int: Int]) -> Data {
        // Encode as [String: Int] since JSON keys must be strings
        let stringKeyed = dict.reduce(into: [String: Int]()) { $0[String($1.key)] = $1.value }
        return (try? JSONEncoder().encode(stringKeyed)) ?? Data()
    }

    private func decodeIntDict(_ data: Data?) -> [Int: Int] {
        guard let data, !data.isEmpty else { return [:] }
        guard let stringKeyed = try? JSONDecoder().decode([String: Int].self, from: data) else { return [:] }
        return stringKeyed.reduce(into: [Int: Int]()) { result, pair in
            if let key = Int(pair.key) {
                result[key] = pair.value
            }
        }
    }
}
