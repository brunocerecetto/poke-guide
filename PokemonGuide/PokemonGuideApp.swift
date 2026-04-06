//
//  PokemonGuideApp.swift
//  PokemonGuide
//
//  Created by Bruno Cerecetto on 6/4/26.
//

import SwiftUI
import CoreData

@main
struct PokemonGuideApp: App {
    @StateObject private var gameConfig: GameConfig
    @StateObject private var progress: ProgressManager
    @StateObject private var bridge: GameDataBridge
    let persistenceController = PersistenceController.shared

    init() {
        let config = GameConfig()
        let context = PersistenceController.shared.container.viewContext
        _gameConfig = StateObject(wrappedValue: config)
        _progress = StateObject(wrappedValue: ProgressManager(prefix: config.progressPrefix))
        _bridge = StateObject(wrappedValue: GameDataBridge(
            gameId: config.gameId,
            starterDex: config.starterDex,
            context: context
        ))

        // Seed Core Data from bundled JSONs on first launch
        let seeder = DataSeeder(persistenceController: PersistenceController.shared)
        seeder.seedIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if gameConfig.isConfigured {
                    ContentView()
                } else {
                    GameListView()
                }
            }
            .environmentObject(gameConfig)
            .environmentObject(progress)
            .environmentObject(bridge)
            .environment(\.themeColors, ThemeColors.forConfig(gameConfig))
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
