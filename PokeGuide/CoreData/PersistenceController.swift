//
//  PersistenceController.swift
//  PokeGuide
//
//  Core Data stack with CloudKit sync.
//  Model is built programmatically — no .xcdatamodeld file required.
//

import CoreData
import CloudKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        // Add sample data for previews here if needed
        try? context.save()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = Self.buildManagedObjectModel()
        container = NSPersistentContainer(name: "PokeGuide", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        } else {
            // Enable lightweight migration for model changes
            if let description = container.persistentStoreDescriptions.first {
                description.shouldMigrateStoreAutomatically = true
                description.shouldInferMappingModelAutomatically = true
            }
        }

        container.loadPersistentStores { description, error in
            if let error {
                print("Core Data store failed to load: \(error.localizedDescription)")
                // If store is incompatible, delete it and retry
                if let storeURL = description.url {
                    print("Deleting incompatible store at: \(storeURL.path)")
                    try? FileManager.default.removeItem(at: storeURL)
                    // Also remove WAL/SHM files
                    try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("wal"))
                    try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("shm"))
                }
            }
        }

        // If store failed and was deleted, retry loading
        if container.persistentStoreCoordinator.persistentStores.isEmpty {
            container.loadPersistentStores { _, error in
                if let error {
                    print("Core Data store failed on retry: \(error.localizedDescription)")
                }
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func saveContext() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Core Data save error: \(error.localizedDescription)")
        }
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    // MARK: - Programmatic Model

    static func buildManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // MARK: Entity Definitions

        let gameEntity = NSEntityDescription()
        gameEntity.name = "CDGame"
        gameEntity.managedObjectClassName = "CDGame"

        let pokemonEntity = NSEntityDescription()
        pokemonEntity.name = "CDPokemon"
        pokemonEntity.managedObjectClassName = "CDPokemon"

        let regionalDexEntry = NSEntityDescription()
        regionalDexEntry.name = "CDRegionalDexEntry"
        regionalDexEntry.managedObjectClassName = "CDRegionalDexEntry"

        let evolutionLink = NSEntityDescription()
        evolutionLink.name = "CDEvolutionLink"
        evolutionLink.managedObjectClassName = "CDEvolutionLink"

        let gymEntity = NSEntityDescription()
        gymEntity.name = "CDGym"
        gymEntity.managedObjectClassName = "CDGym"

        let routeSectionEntity = NSEntityDescription()
        routeSectionEntity.name = "CDRouteSection"
        routeSectionEntity.managedObjectClassName = "CDRouteSection"

        let routeStepEntity = NSEntityDescription()
        routeStepEntity.name = "CDRouteStep"
        routeStepEntity.managedObjectClassName = "CDRouteStep"

        let progressEntity = NSEntityDescription()
        progressEntity.name = "CDProgress"
        progressEntity.managedObjectClassName = "CDProgress"

        let eliteFourEntity = NSEntityDescription()
        eliteFourEntity.name = "CDEliteFourMember"
        eliteFourEntity.managedObjectClassName = "CDEliteFourMember"

        let tipEntity = NSEntityDescription()
        tipEntity.name = "CDTip"
        tipEntity.managedObjectClassName = "CDTip"

        let keyCaptureEntity = NSEntityDescription()
        keyCaptureEntity.name = "CDKeyCapture"
        keyCaptureEntity.managedObjectClassName = "CDKeyCapture"

        let hmEntryEntity = NSEntityDescription()
        hmEntryEntity.name = "CDHMEntry"
        hmEntryEntity.managedObjectClassName = "CDHMEntry"

        let tmEntryEntity = NSEntityDescription()
        tmEntryEntity.name = "CDTMEntry"
        tmEntryEntity.managedObjectClassName = "CDTMEntry"

        let teamRecommendationEntity = NSEntityDescription()
        teamRecommendationEntity.name = "CDTeamRecommendation"
        teamRecommendationEntity.managedObjectClassName = "CDTeamRecommendation"

        let teamMemberEntity = NSEntityDescription()
        teamMemberEntity.name = "CDTeamMember"
        teamMemberEntity.managedObjectClassName = "CDTeamMember"

        let preLeagueStepEntity = NSEntityDescription()
        preLeagueStepEntity.name = "CDPreLeagueStep"
        preLeagueStepEntity.managedObjectClassName = "CDPreLeagueStep"

        let postgameStepEntity = NSEntityDescription()
        postgameStepEntity.name = "CDPostgameStep"
        postgameStepEntity.managedObjectClassName = "CDPostgameStep"

        // MARK: Game Attributes

        gameEntity.properties = [
            makeStringAttribute("id"),
            makeStringAttribute("name"),
            makeInt16Attribute("generation"),
            makeStringAttribute("region"),
            makeInt16Attribute("releaseYear"),
            makeStringAttribute("platform"),
            makeStringAttribute("accentColorHex"),
            makeStringAttribute("secondaryColorHex"),
            makeStringAttribute("iconName"),
            makeBinaryAttribute("starterDexNumbersData"),
            makeInt16Attribute("gymCount"),
            makeBoolAttribute("hasEliteFour"),
            makeBoolAttribute("hasChampion"),
        ]

        // MARK: Pokemon Attributes

        pokemonEntity.properties = [
            makeInt32Attribute("dexNumber"),
            makeStringAttribute("name"),
            makeBinaryAttribute("typesData"),
            makeInt16Attribute("hp"),
            makeInt16Attribute("attack"),
            makeInt16Attribute("defense"),
            makeInt16Attribute("spAttack"),
            makeInt16Attribute("spDefense"),
            makeInt16Attribute("speed"),
            makeInt16Attribute("generation"),
        ]

        // MARK: RegionalDexEntry Attributes

        regionalDexEntry.properties = [
            makeInt32Attribute("regionalDexNumber"),
            makeStringAttribute("location"),
            makeOptionalStringAttribute("availability"),
        ]

        // MARK: EvolutionLink Attributes

        evolutionLink.properties = [
            makeInt32Attribute("fromDexNumber"),
            makeInt32Attribute("toDexNumber"),
            makeStringAttribute("method"),
            makeStringAttribute("detail"),
        ]

        // MARK: Gym Attributes

        gymEntity.properties = [
            makeInt16Attribute("orderIndex"),
            makeStringAttribute("name"),
            makeStringAttribute("leader"),
            makeStringAttribute("levelRange"),
            makeStringAttribute("note"),
            makeStringAttribute("badge"),
        ]

        // MARK: RouteSection Attributes

        routeSectionEntity.properties = [
            makeInt16Attribute("orderIndex"),
            makeStringAttribute("title"),
        ]

        // MARK: RouteStep Attributes

        routeStepEntity.properties = [
            makeStringAttribute("stepId"),
            makeStringAttribute("text"),
            makeInt16Attribute("orderIndex"),
        ]

        // MARK: Progress Attributes

        progressEntity.properties = [
            makeStringAttribute("gameId"),
            makeStringAttribute("starterId"),
            makeBinaryAttribute("completedGymsData"),
            makeBinaryAttribute("completedRouteStepsData"),
            makeBinaryAttribute("completedLeagueData"),
            makeBinaryAttribute("completedPreLeagueData"),
            makeBinaryAttribute("completedPostgameData"),
            makeBinaryAttribute("pokemonStatusesData"),
            makeDateAttribute("lastModified"),
        ]

        // MARK: EliteFourMember Attributes

        eliteFourEntity.properties = [
            makeInt16Attribute("orderIndex"),
            makeStringAttribute("name"),
            makeStringAttribute("strategy"),
            makeStringAttribute("levels"),
        ]

        // MARK: Tip Attributes

        tipEntity.properties = [
            makeInt16Attribute("orderIndex"),
            makeStringAttribute("pokemon"),
            makeStringAttribute("rule"),
        ]

        // MARK: KeyCapture Attributes

        keyCaptureEntity.properties = [
            makeInt16Attribute("orderIndex"),
            makeStringAttribute("pokemon"),
            makeStringAttribute("location"),
            makeStringAttribute("note"),
        ]

        // MARK: HMEntry Attributes

        hmEntryEntity.properties = [
            makeInt16Attribute("orderIndex"),
            makeStringAttribute("hm"),
            makeStringAttribute("pokemon"),
            makeStringAttribute("location"),
        ]

        // MARK: TMEntry Attributes

        tmEntryEntity.properties = [
            makeInt16Attribute("orderIndex"),
            makeStringAttribute("tm"),
            makeStringAttribute("target"),
            makeStringAttribute("origin"),
        ]

        // MARK: TeamRecommendation Attributes

        teamRecommendationEntity.properties = [
            makeStringAttribute("starterCondition"),
        ]

        // MARK: TeamMember Attributes

        teamMemberEntity.properties = [
            makeInt16Attribute("orderIndex"),
            makeStringAttribute("name"),
            makeBinaryAttribute("movesData"),
            makeStringAttribute("notes"),
            makeStringAttribute("emoji"),
        ]

        // MARK: PreLeagueStep Attributes

        preLeagueStepEntity.properties = [
            makeStringAttribute("stepId"),
            makeStringAttribute("text"),
            makeInt16Attribute("orderIndex"),
        ]

        // MARK: PostgameStep Attributes

        postgameStepEntity.properties = [
            makeStringAttribute("stepId"),
            makeStringAttribute("text"),
            makeInt16Attribute("orderIndex"),
        ]

        // MARK: Relationships

        // Game -> Gyms (one-to-many)
        let gameGymsRel = makeToManyRelation("gyms", destination: gymEntity)
        let gymGameRel = makeToOneRelation("game", destination: gameEntity)
        gameGymsRel.inverseRelationship = gymGameRel
        gymGameRel.inverseRelationship = gameGymsRel

        // Game -> RouteSections (one-to-many)
        let gameRouteSectionsRel = makeToManyRelation("routeSections", destination: routeSectionEntity)
        let routeSectionGameRel = makeToOneRelation("game", destination: gameEntity)
        gameRouteSectionsRel.inverseRelationship = routeSectionGameRel
        routeSectionGameRel.inverseRelationship = gameRouteSectionsRel

        // RouteSection -> RouteSteps (one-to-many)
        let sectionStepsRel = makeToManyRelation("steps", destination: routeStepEntity)
        let stepSectionRel = makeToOneRelation("section", destination: routeSectionEntity)
        sectionStepsRel.inverseRelationship = stepSectionRel
        stepSectionRel.inverseRelationship = sectionStepsRel

        // Game -> EliteFourMembers (one-to-many)
        let gameEliteFourRel = makeToManyRelation("eliteFourMembers", destination: eliteFourEntity)
        let eliteFourGameRel = makeToOneRelation("game", destination: gameEntity)
        gameEliteFourRel.inverseRelationship = eliteFourGameRel
        eliteFourGameRel.inverseRelationship = gameEliteFourRel

        // Game -> Tips (one-to-many)
        let gameTipsRel = makeToManyRelation("tips", destination: tipEntity)
        let tipGameRel = makeToOneRelation("game", destination: gameEntity)
        gameTipsRel.inverseRelationship = tipGameRel
        tipGameRel.inverseRelationship = gameTipsRel

        // Game -> KeyCaptures (one-to-many)
        let gameCapturesRel = makeToManyRelation("captures", destination: keyCaptureEntity)
        let captureGameRel = makeToOneRelation("game", destination: gameEntity)
        gameCapturesRel.inverseRelationship = captureGameRel
        captureGameRel.inverseRelationship = gameCapturesRel

        // Game -> HMEntries (one-to-many)
        let gameHMEntriesRel = makeToManyRelation("hmEntries", destination: hmEntryEntity)
        let hmEntryGameRel = makeToOneRelation("game", destination: gameEntity)
        gameHMEntriesRel.inverseRelationship = hmEntryGameRel
        hmEntryGameRel.inverseRelationship = gameHMEntriesRel

        // Game -> TMEntries (one-to-many)
        let gameTMEntriesRel = makeToManyRelation("tmEntries", destination: tmEntryEntity)
        let tmEntryGameRel = makeToOneRelation("game", destination: gameEntity)
        gameTMEntriesRel.inverseRelationship = tmEntryGameRel
        tmEntryGameRel.inverseRelationship = gameTMEntriesRel

        // Game -> TeamRecommendations (one-to-many)
        let gameTeamRecsRel = makeToManyRelation("teamRecommendations", destination: teamRecommendationEntity)
        let teamRecGameRel = makeToOneRelation("game", destination: gameEntity)
        gameTeamRecsRel.inverseRelationship = teamRecGameRel
        teamRecGameRel.inverseRelationship = gameTeamRecsRel

        // TeamRecommendation -> TeamMembers (one-to-many)
        let recMembersRel = makeToManyRelation("members", destination: teamMemberEntity)
        let memberRecRel = makeToOneRelation("recommendation", destination: teamRecommendationEntity)
        recMembersRel.inverseRelationship = memberRecRel
        memberRecRel.inverseRelationship = recMembersRel

        // Game -> PreLeagueSteps (one-to-many)
        let gamePreLeagueRel = makeToManyRelation("preLeagueSteps", destination: preLeagueStepEntity)
        let preLeagueGameRel = makeToOneRelation("game", destination: gameEntity)
        gamePreLeagueRel.inverseRelationship = preLeagueGameRel
        preLeagueGameRel.inverseRelationship = gamePreLeagueRel

        // Game -> PostgameSteps (one-to-many)
        let gamePostgameRel = makeToManyRelation("postgameSteps", destination: postgameStepEntity)
        let postgameGameRel = makeToOneRelation("game", destination: gameEntity)
        gamePostgameRel.inverseRelationship = postgameGameRel
        postgameGameRel.inverseRelationship = gamePostgameRel

        // Pokemon -> RegionalDexEntries (one-to-many)
        let pokemonRegionalRel = makeToManyRelation("regionalEntries", destination: regionalDexEntry)
        let regionalPokemonRel = makeToOneRelation("pokemon", destination: pokemonEntity)
        pokemonRegionalRel.inverseRelationship = regionalPokemonRel
        regionalPokemonRel.inverseRelationship = pokemonRegionalRel

        // Game -> RegionalDexEntries (one-to-many)
        let gameRegionalRel = makeToManyRelation("regionalDexEntries", destination: regionalDexEntry)
        let regionalGameRel = makeToOneRelation("game", destination: gameEntity)
        gameRegionalRel.inverseRelationship = regionalGameRel
        regionalGameRel.inverseRelationship = gameRegionalRel

        // Pokemon -> EvolutionLinks (from / to)
        let pokemonEvoFromRel = makeToManyRelation("evolutionsFrom", destination: evolutionLink)
        let evoFromPokemonRel = makeToOneRelation("fromPokemon", destination: pokemonEntity)
        pokemonEvoFromRel.inverseRelationship = evoFromPokemonRel
        evoFromPokemonRel.inverseRelationship = pokemonEvoFromRel

        let pokemonEvoToRel = makeToManyRelation("evolutionsTo", destination: evolutionLink)
        let evoToPokemonRel = makeToOneRelation("toPokemon", destination: pokemonEntity)
        pokemonEvoToRel.inverseRelationship = evoToPokemonRel
        evoToPokemonRel.inverseRelationship = pokemonEvoToRel

        // MARK: Attach Relationships to Entities

        gameEntity.properties.append(contentsOf: [
            gameGymsRel, gameRouteSectionsRel,
            gameEliteFourRel, gameTipsRel, gameCapturesRel,
            gameHMEntriesRel, gameTMEntriesRel, gameTeamRecsRel,
            gamePreLeagueRel, gamePostgameRel, gameRegionalRel,
        ])

        pokemonEntity.properties.append(contentsOf: [
            pokemonRegionalRel, pokemonEvoFromRel, pokemonEvoToRel,
        ])

        regionalDexEntry.properties.append(contentsOf: [regionalPokemonRel, regionalGameRel])
        evolutionLink.properties.append(contentsOf: [evoFromPokemonRel, evoToPokemonRel])
        gymEntity.properties.append(gymGameRel)
        routeSectionEntity.properties.append(contentsOf: [routeSectionGameRel, sectionStepsRel])
        routeStepEntity.properties.append(stepSectionRel)
        eliteFourEntity.properties.append(eliteFourGameRel)
        tipEntity.properties.append(tipGameRel)
        keyCaptureEntity.properties.append(captureGameRel)
        hmEntryEntity.properties.append(hmEntryGameRel)
        tmEntryEntity.properties.append(tmEntryGameRel)
        teamRecommendationEntity.properties.append(contentsOf: [teamRecGameRel, recMembersRel])
        teamMemberEntity.properties.append(memberRecRel)
        preLeagueStepEntity.properties.append(preLeagueGameRel)
        postgameStepEntity.properties.append(postgameGameRel)

        // MARK: Uniqueness Constraints

        gameEntity.uniquenessConstraints = [["id"]]
        pokemonEntity.uniquenessConstraints = [["dexNumber"]]

        // MARK: Register Entities

        model.entities = [
            gameEntity, pokemonEntity, regionalDexEntry, evolutionLink,
            gymEntity, routeSectionEntity, routeStepEntity, progressEntity,
            eliteFourEntity,
            tipEntity, keyCaptureEntity, hmEntryEntity, tmEntryEntity,
            teamRecommendationEntity, teamMemberEntity,
            preLeagueStepEntity, postgameStepEntity,
        ]

        return model
    }

    // MARK: - Attribute Helpers

    private static func makeStringAttribute(_ name: String) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = .stringAttributeType
        attr.isOptional = false
        return attr
    }

    private static func makeOptionalStringAttribute(_ name: String) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = .stringAttributeType
        attr.isOptional = true
        return attr
    }

    private static func makeInt16Attribute(_ name: String) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = .integer16AttributeType
        attr.isOptional = false
        attr.defaultValue = Int16(0)
        return attr
    }

    private static func makeInt32Attribute(_ name: String) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = .integer32AttributeType
        attr.isOptional = false
        attr.defaultValue = Int32(0)
        return attr
    }

    private static func makeBoolAttribute(_ name: String) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = .booleanAttributeType
        attr.isOptional = false
        attr.defaultValue = false
        return attr
    }

    private static func makeBinaryAttribute(_ name: String) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = .binaryDataAttributeType
        attr.isOptional = true
        return attr
    }

    private static func makeDateAttribute(_ name: String) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = .dateAttributeType
        attr.isOptional = true
        return attr
    }

    // MARK: - Relationship Helpers

    private static func makeToManyRelation(
        _ name: String,
        destination: NSEntityDescription
    ) -> NSRelationshipDescription {
        let rel = NSRelationshipDescription()
        rel.name = name
        rel.destinationEntity = destination
        rel.minCount = 0
        rel.maxCount = 0 // 0 means to-many
        rel.deleteRule = .cascadeDeleteRule
        rel.isOptional = true
        return rel
    }

    private static func makeToOneRelation(
        _ name: String,
        destination: NSEntityDescription
    ) -> NSRelationshipDescription {
        let rel = NSRelationshipDescription()
        rel.name = name
        rel.destinationEntity = destination
        rel.minCount = 0
        rel.maxCount = 1
        rel.deleteRule = .nullifyDeleteRule
        rel.isOptional = true
        return rel
    }
}

// MARK: - NSManagedObject Subclasses with JSON Helpers

@objc(CDGame)
public class CDGame: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var generation: Int16
    @NSManaged var region: String
    @NSManaged var releaseYear: Int16
    @NSManaged var platform: String
    @NSManaged var accentColorHex: String
    @NSManaged var secondaryColorHex: String
    @NSManaged var iconName: String
    @NSManaged var starterDexNumbersData: Data?
    @NSManaged var gymCount: Int16
    @NSManaged var hasEliteFour: Bool
    @NSManaged var hasChampion: Bool

    @NSManaged var gyms: NSSet?
    @NSManaged var routeSections: NSSet?
    @NSManaged var eliteFourMembers: NSSet?
    @NSManaged var tips: NSSet?
    @NSManaged var captures: NSSet?
    @NSManaged var hmEntries: NSSet?
    @NSManaged var tmEntries: NSSet?
    @NSManaged var teamRecommendations: NSSet?
    @NSManaged var preLeagueSteps: NSSet?
    @NSManaged var postgameSteps: NSSet?
    @NSManaged var regionalDexEntries: NSSet?

    var starterDexNumbers: [Int] {
        get { decodeJSON(starterDexNumbersData) ?? [] }
        set { starterDexNumbersData = encodeJSON(newValue) }
    }
}

@objc(CDPokemon)
public class CDPokemon: NSManagedObject {
    @NSManaged var dexNumber: Int32
    @NSManaged var name: String
    @NSManaged var typesData: Data?
    @NSManaged var hp: Int16
    @NSManaged var attack: Int16
    @NSManaged var defense: Int16
    @NSManaged var spAttack: Int16
    @NSManaged var spDefense: Int16
    @NSManaged var speed: Int16
    @NSManaged var generation: Int16

    @NSManaged var regionalEntries: NSSet?
    @NSManaged var evolutionsFrom: NSSet?
    @NSManaged var evolutionsTo: NSSet?

    var types: [String] {
        get { decodeJSON(typesData) ?? [] }
        set { typesData = encodeJSON(newValue) }
    }
}

@objc(CDRegionalDexEntry)
public class CDRegionalDexEntry: NSManagedObject {
    @NSManaged var regionalDexNumber: Int32
    @NSManaged var location: String
    @NSManaged var availability: String?
    @NSManaged var game: CDGame?
    @NSManaged var pokemon: CDPokemon?
}

@objc(CDEvolutionLink)
public class CDEvolutionLink: NSManagedObject {
    @NSManaged var fromDexNumber: Int32
    @NSManaged var toDexNumber: Int32
    @NSManaged var method: String
    @NSManaged var detail: String
    @NSManaged var fromPokemon: CDPokemon?
    @NSManaged var toPokemon: CDPokemon?
}

@objc(CDGym)
public class CDGym: NSManagedObject {
    @NSManaged var orderIndex: Int16
    @NSManaged var name: String
    @NSManaged var leader: String
    @NSManaged var levelRange: String
    @NSManaged var note: String
    @NSManaged var badge: String
    @NSManaged var game: CDGame?
}

@objc(CDRouteSection)
public class CDRouteSection: NSManagedObject {
    @NSManaged var orderIndex: Int16
    @NSManaged var title: String
    @NSManaged var game: CDGame?
    @NSManaged var steps: NSSet?
}

@objc(CDRouteStep)
public class CDRouteStep: NSManagedObject {
    @NSManaged var stepId: String
    @NSManaged var text: String
    @NSManaged var orderIndex: Int16
    @NSManaged var section: CDRouteSection?
}

@objc(CDProgress)
public class CDProgress: NSManagedObject {
    @NSManaged var gameId: String
    @NSManaged var starterId: String
    @NSManaged var completedGymsData: Data?
    @NSManaged var completedRouteStepsData: Data?
    @NSManaged var completedLeagueData: Data?
    @NSManaged var completedPreLeagueData: Data?
    @NSManaged var completedPostgameData: Data?
    @NSManaged var pokemonStatusesData: Data?
    @NSManaged var lastModified: Date?

    var completedGyms: [String] {
        get { decodeJSON(completedGymsData) ?? [] }
        set { completedGymsData = encodeJSON(newValue) }
    }

    var completedRouteSteps: [String] {
        get { decodeJSON(completedRouteStepsData) ?? [] }
        set { completedRouteStepsData = encodeJSON(newValue) }
    }

    var completedLeague: [String] {
        get { decodeJSON(completedLeagueData) ?? [] }
        set { completedLeagueData = encodeJSON(newValue) }
    }

    var completedPreLeague: [String] {
        get { decodeJSON(completedPreLeagueData) ?? [] }
        set { completedPreLeagueData = encodeJSON(newValue) }
    }

    var completedPostgame: [String] {
        get { decodeJSON(completedPostgameData) ?? [] }
        set { completedPostgameData = encodeJSON(newValue) }
    }

    var pokemonStatuses: [Int: Int] {
        get { decodeJSON(pokemonStatusesData) ?? [:] }
        set { pokemonStatusesData = encodeJSON(newValue) }
    }
}

@objc(CDEliteFourMember)
public class CDEliteFourMember: NSManagedObject {
    @NSManaged var orderIndex: Int16
    @NSManaged var name: String
    @NSManaged var strategy: String
    @NSManaged var levels: String
    @NSManaged var game: CDGame?
}

@objc(CDTip)
public class CDTip: NSManagedObject {
    @NSManaged var orderIndex: Int16
    @NSManaged var pokemon: String
    @NSManaged var rule: String
    @NSManaged var game: CDGame?
}

@objc(CDKeyCapture)
public class CDKeyCapture: NSManagedObject {
    @NSManaged var orderIndex: Int16
    @NSManaged var pokemon: String
    @NSManaged var location: String
    @NSManaged var note: String
    @NSManaged var game: CDGame?
}

@objc(CDHMEntry)
public class CDHMEntry: NSManagedObject {
    @NSManaged var orderIndex: Int16
    @NSManaged var hm: String
    @NSManaged var pokemon: String
    @NSManaged var location: String
    @NSManaged var game: CDGame?
}

@objc(CDTMEntry)
public class CDTMEntry: NSManagedObject {
    @NSManaged var orderIndex: Int16
    @NSManaged var tm: String
    @NSManaged var target: String
    @NSManaged var origin: String
    @NSManaged var game: CDGame?
}

@objc(CDTeamRecommendation)
public class CDTeamRecommendation: NSManagedObject {
    @NSManaged var starterCondition: String
    @NSManaged var game: CDGame?
    @NSManaged var members: NSSet?
}

@objc(CDTeamMember)
public class CDTeamMember: NSManagedObject {
    @NSManaged var orderIndex: Int16
    @NSManaged var name: String
    @NSManaged var movesData: Data?
    @NSManaged var notes: String
    @NSManaged var emoji: String
    @NSManaged var recommendation: CDTeamRecommendation?

    var moves: [String] {
        get { decodeJSON(movesData) ?? [] }
        set { movesData = encodeJSON(newValue) }
    }
}

@objc(CDPreLeagueStep)
public class CDPreLeagueStep: NSManagedObject {
    @NSManaged var stepId: String
    @NSManaged var text: String
    @NSManaged var orderIndex: Int16
    @NSManaged var game: CDGame?
}

@objc(CDPostgameStep)
public class CDPostgameStep: NSManagedObject {
    @NSManaged var stepId: String
    @NSManaged var text: String
    @NSManaged var orderIndex: Int16
    @NSManaged var game: CDGame?
}

// MARK: - JSON Encode/Decode Helpers

private func encodeJSON<T: Encodable>(_ value: T) -> Data? {
    try? JSONEncoder().encode(value)
}

private func decodeJSON<T: Decodable>(_ data: Data?) -> T? {
    guard let data else { return nil }
    return try? JSONDecoder().decode(T.self, from: data)
}
