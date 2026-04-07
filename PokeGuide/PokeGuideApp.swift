//
//  PokeGuideApp.swift
//  PokeGuide
//
//  Created by Bruno Cerecetto on 6/4/26.
//

import SwiftUI
import CoreData

@main
struct PokeGuideApp: App {
    @StateObject private var gameConfig: GameConfig
    @StateObject private var progress: ProgressManager
    @StateObject private var bridge: GameDataBridge

    init() {
        let config = GameConfig()
        _gameConfig = StateObject(wrappedValue: config)
        _progress = StateObject(wrappedValue: ProgressManager(prefix: config.progressPrefix))

        // Try to initialize Core Data — fall back to nil context if it fails
        let persistence = PersistenceController.shared
        let context: NSManagedObjectContext? = persistence.container.persistentStoreCoordinator.persistentStores.isEmpty
            ? nil
            : persistence.container.viewContext

        _bridge = StateObject(wrappedValue: GameDataBridge(
            gameId: config.gameId,
            starterDex: config.starterDex,
            context: context
        ))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if gameConfig.isConfigured {
                    MainTabView()
                } else {
                    GameListView()
                }
            }
            .environmentObject(gameConfig)
            .environmentObject(progress)
            .environmentObject(bridge)
            .environment(\.themeColors, ThemeColors.forConfig(gameConfig))
        }
    }
}
