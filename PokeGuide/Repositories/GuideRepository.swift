//
//  GuideRepository.swift
//  PokeGuide
//
//  Repository layer for querying game guide content from Core Data.
//  Covers games, gyms, routes, elite four, tips, captures, HM/TM,
//  team recommendations, and checklists.
//

import Foundation
import CoreData
import Combine

// MARK: - DTOs

struct GameDTO: Identifiable, Equatable {
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
}

struct GymDTO: Identifiable, Equatable {
    let id: Int
    let name: String
    let leader: String
    let levelRange: String
    let note: String
    let badge: String
    let badgeSpriteId: Int?
}

struct RouteSectionDTO: Identifiable, Equatable {
    let id: Int
    let title: String
    let steps: [RouteStepDTO]
}

struct RouteStepDTO: Identifiable, Equatable {
    let id: String
    let text: String
}

struct EliteFourMemberDTO: Identifiable, Equatable {
    let id: Int
    let name: String
    let strategy: String
    let levels: String
}

struct TipDTO: Identifiable, Equatable {
    let id: Int
    let pokemon: String
    let rule: String
}

struct KeyCaptureDTO: Identifiable, Equatable {
    let id: Int
    let pokemon: String
    let location: String
    let note: String
}

struct HMEntryDTO: Identifiable, Equatable {
    let id: Int
    let hm: String
    let pokemon: String
    let location: String
}

struct TMEntryDTO: Identifiable, Equatable {
    let id: Int
    let tm: String
    let target: String
    let origin: String
}

struct TeamRecommendationDTO: Equatable {
    let starterCondition: String
    let members: [TeamMemberDTO]
}

struct TeamMemberDTO: Identifiable, Equatable {
    let id: Int
    let name: String
    let moves: [String]
    let notes: String
    let emoji: String
}

struct ChecklistStepDTO: Identifiable, Equatable {
    let id: String
    let text: String
}

// MARK: - Repository

class GuideRepository: ObservableObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Games

    func allGames() -> [GameDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDGame")
        request.sortDescriptors = [
            NSSortDescriptor(key: "generation", ascending: true),
            NSSortDescriptor(key: "releaseYear", ascending: true),
        ]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (allGames): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToGameDTO($0) }
    }

    func allGames(generation: Int) -> [GameDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDGame")
        request.predicate = NSPredicate(format: "generation == %d", generation)
        request.sortDescriptors = [NSSortDescriptor(key: "releaseYear", ascending: true)]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (allGames by generation): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToGameDTO($0) }
    }

    func game(id: String) -> GameDTO? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDGame")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (game by id): \(error.localizedDescription)")
            return nil
        }
        guard let result = results.first else { return nil }
        return mapToGameDTO(result)
    }

    func generations() -> [Int] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDGame")
        request.propertiesToFetch = ["generation"]
        request.returnsDistinctResults = true
        request.resultType = .dictionaryResultType

        let rawResults: [Any]
        do {
            rawResults = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (generations): \(error.localizedDescription)")
            return []
        }
        guard let results = rawResults as? [[String: Any]] else { return [] }
        return results
            .compactMap { $0["generation"] as? Int }
            .sorted()
    }

    // MARK: - Gyms

    func gyms(gameId: String) -> [GymDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDGym")
        request.predicate = NSPredicate(format: "game.id == %@", gameId)
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (gyms): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToGymDTO($0) }
    }

    // MARK: - Route sections & steps

    func routeSections(gameId: String) -> [RouteSectionDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDRouteSection")
        request.predicate = NSPredicate(format: "game.id == %@", gameId)
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (routeSections): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToRouteSectionDTO($0) }
    }

    // MARK: - Elite Four

    func eliteFour(gameId: String) -> [EliteFourMemberDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDEliteFourMember")
        request.predicate = NSPredicate(format: "game.id == %@", gameId)
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (eliteFour): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToEliteFourMemberDTO($0) }
    }

    // MARK: - Tips

    func tips(gameId: String) -> [TipDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDTip")
        request.predicate = NSPredicate(format: "game.id == %@", gameId)
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (tips): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToTipDTO($0) }
    }

    // MARK: - Key captures

    func captures(gameId: String) -> [KeyCaptureDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDKeyCapture")
        request.predicate = NSPredicate(format: "game.id == %@", gameId)
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (captures): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToKeyCaptureDTO($0) }
    }

    // MARK: - HM / TM entries

    func hmEntries(gameId: String) -> [HMEntryDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDHMEntry")
        request.predicate = NSPredicate(format: "game.id == %@", gameId)
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (hmEntries): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToHMEntryDTO($0) }
    }

    func tmEntries(gameId: String) -> [TMEntryDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDTMEntry")
        request.predicate = NSPredicate(format: "game.id == %@", gameId)
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (tmEntries): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToTMEntryDTO($0) }
    }

    // MARK: - Team recommendations

    func teamRecommendation(gameId: String, starter: String) -> TeamRecommendationDTO? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDTeamRecommendation")
        request.predicate = NSPredicate(
            format: "game.id == %@ AND starterCondition == %@", gameId, starter
        )
        request.fetchLimit = 1

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (teamRecommendation): \(error.localizedDescription)")
            return nil
        }
        guard let result = results.first else { return nil }
        return mapToTeamRecommendationDTO(result)
    }

    // MARK: - Pre-league / Postgame checklists

    func preLeagueChecklist(gameId: String) -> [ChecklistStepDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDPreLeagueStep")
        request.predicate = NSPredicate(format: "game.id == %@", gameId)
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (preLeagueChecklist): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToChecklistStepDTO($0) }
    }

    func postgameChecklist(gameId: String) -> [ChecklistStepDTO] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDPostgameStep")
        request.predicate = NSPredicate(format: "game.id == %@", gameId)
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]

        let results: [NSManagedObject]
        do {
            results = try context.fetch(request)
        } catch {
            print("[GuideRepository] Fetch error (postgameChecklist): \(error.localizedDescription)")
            return []
        }
        return results.compactMap { mapToChecklistStepDTO($0) }
    }

    // MARK: - Mapping helpers

    private func mapToGameDTO(_ object: NSManagedObject) -> GameDTO? {
        guard let id = object.value(forKey: "id") as? String,
              let name = object.value(forKey: "name") as? String
        else { return nil }

        return GameDTO(
            id: id,
            name: name,
            generation: object.value(forKey: "generation") as? Int ?? 1,
            region: object.value(forKey: "region") as? String ?? "",
            releaseYear: object.value(forKey: "releaseYear") as? Int ?? 0,
            platform: object.value(forKey: "platform") as? String ?? "",
            accentColorHex: object.value(forKey: "accentColorHex") as? String ?? "#FF0000",
            secondaryColorHex: object.value(forKey: "secondaryColorHex") as? String ?? "#0000FF",
            iconName: object.value(forKey: "iconName") as? String ?? "",
            starterDexNumbers: decodeJSONIntArray(object.value(forKey: "starterDexNumbersJSON") as? Data),
            gymCount: object.value(forKey: "gymCount") as? Int ?? 8,
            hasEliteFour: object.value(forKey: "hasEliteFour") as? Bool ?? true,
            hasChampion: object.value(forKey: "hasChampion") as? Bool ?? true
        )
    }

    private func mapToGymDTO(_ object: NSManagedObject) -> GymDTO? {
        guard let orderIndex = object.value(forKey: "orderIndex") as? Int else { return nil }

        return GymDTO(
            id: orderIndex,
            name: object.value(forKey: "name") as? String ?? "",
            leader: object.value(forKey: "leader") as? String ?? "",
            levelRange: object.value(forKey: "levelRange") as? String ?? "",
            note: object.value(forKey: "note") as? String ?? "",
            badge: object.value(forKey: "badge") as? String ?? "",
            badgeSpriteId: object.value(forKey: "badgeSpriteId") as? Int
        )
    }

    private func mapToRouteSectionDTO(_ object: NSManagedObject) -> RouteSectionDTO? {
        guard let orderIndex = object.value(forKey: "orderIndex") as? Int else { return nil }

        let stepsSet = object.value(forKey: "steps") as? NSSet ?? NSSet()
        let stepsArray = stepsSet.allObjects as? [NSManagedObject] ?? []

        let steps = stepsArray
            .sorted { ($0.value(forKey: "orderIndex") as? Int ?? 0) < ($1.value(forKey: "orderIndex") as? Int ?? 0) }
            .compactMap { step -> RouteStepDTO? in
                guard let stepId = step.value(forKey: "stepId") as? String else { return nil }
                return RouteStepDTO(
                    id: stepId,
                    text: step.value(forKey: "text") as? String ?? ""
                )
            }

        return RouteSectionDTO(
            id: orderIndex,
            title: object.value(forKey: "title") as? String ?? "",
            steps: steps
        )
    }

    private func mapToEliteFourMemberDTO(_ object: NSManagedObject) -> EliteFourMemberDTO? {
        guard let orderIndex = object.value(forKey: "orderIndex") as? Int else { return nil }

        return EliteFourMemberDTO(
            id: orderIndex,
            name: object.value(forKey: "name") as? String ?? "",
            strategy: object.value(forKey: "strategy") as? String ?? "",
            levels: object.value(forKey: "levels") as? String ?? ""
        )
    }

    private func mapToTipDTO(_ object: NSManagedObject) -> TipDTO? {
        guard let orderIndex = object.value(forKey: "orderIndex") as? Int else { return nil }

        return TipDTO(
            id: orderIndex,
            pokemon: object.value(forKey: "pokemon") as? String ?? "",
            rule: object.value(forKey: "rule") as? String ?? ""
        )
    }

    private func mapToKeyCaptureDTO(_ object: NSManagedObject) -> KeyCaptureDTO? {
        guard let orderIndex = object.value(forKey: "orderIndex") as? Int else { return nil }

        return KeyCaptureDTO(
            id: orderIndex,
            pokemon: object.value(forKey: "pokemon") as? String ?? "",
            location: object.value(forKey: "location") as? String ?? "",
            note: object.value(forKey: "note") as? String ?? ""
        )
    }

    private func mapToHMEntryDTO(_ object: NSManagedObject) -> HMEntryDTO? {
        guard let orderIndex = object.value(forKey: "orderIndex") as? Int else { return nil }

        return HMEntryDTO(
            id: orderIndex,
            hm: object.value(forKey: "hm") as? String ?? "",
            pokemon: object.value(forKey: "pokemon") as? String ?? "",
            location: object.value(forKey: "location") as? String ?? ""
        )
    }

    private func mapToTMEntryDTO(_ object: NSManagedObject) -> TMEntryDTO? {
        guard let orderIndex = object.value(forKey: "orderIndex") as? Int else { return nil }

        return TMEntryDTO(
            id: orderIndex,
            tm: object.value(forKey: "tm") as? String ?? "",
            target: object.value(forKey: "target") as? String ?? "",
            origin: object.value(forKey: "origin") as? String ?? ""
        )
    }

    private func mapToTeamRecommendationDTO(_ object: NSManagedObject) -> TeamRecommendationDTO? {
        let starterCondition = object.value(forKey: "starterCondition") as? String ?? ""
        let membersSet = object.value(forKey: "members") as? NSSet ?? NSSet()
        let membersArray = membersSet.allObjects as? [NSManagedObject] ?? []

        let members = membersArray
            .sorted { ($0.value(forKey: "orderIndex") as? Int ?? 0) < ($1.value(forKey: "orderIndex") as? Int ?? 0) }
            .compactMap { member -> TeamMemberDTO? in
                guard let orderIndex = member.value(forKey: "orderIndex") as? Int else { return nil }
                return TeamMemberDTO(
                    id: orderIndex,
                    name: member.value(forKey: "name") as? String ?? "",
                    moves: decodeJSONStringArray(member.value(forKey: "movesJSON") as? Data),
                    notes: member.value(forKey: "notes") as? String ?? "",
                    emoji: member.value(forKey: "emoji") as? String ?? ""
                )
            }

        return TeamRecommendationDTO(
            starterCondition: starterCondition,
            members: members
        )
    }

    private func mapToChecklistStepDTO(_ object: NSManagedObject) -> ChecklistStepDTO? {
        guard let stepId = object.value(forKey: "stepId") as? String else { return nil }

        return ChecklistStepDTO(
            id: stepId,
            text: object.value(forKey: "text") as? String ?? ""
        )
    }

    // MARK: - JSON decoding

    private func decodeJSONStringArray(_ data: Data?) -> [String] {
        guard let data else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    private func decodeJSONIntArray(_ data: Data?) -> [Int] {
        guard let data else { return [] }
        return (try? JSONDecoder().decode([Int].self, from: data)) ?? []
    }
}
