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
    let persistenceController = PersistenceController.shared

    init() {
        let config = GameConfig()
        _gameConfig = StateObject(wrappedValue: config)
        _progress = StateObject(wrappedValue: ProgressManager(prefix: config.progressPrefix))
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
            .environment(\.themeColors, ThemeColors.forConfig(gameConfig))
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
