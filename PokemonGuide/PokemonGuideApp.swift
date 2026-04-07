//
//  PokemonGuideApp.swift
//  PokemonGuide
//
//  Created by Bruno Cerecetto on 6/4/26.
//

import SwiftUI

@main
struct PokemonGuideApp: App {
    @StateObject private var gameConfig: GameConfig
    @StateObject private var progress: ProgressManager
    @StateObject private var bridge: GameDataBridge

    init() {
        let config = GameConfig()
        _gameConfig = StateObject(wrappedValue: config)
        _progress = StateObject(wrappedValue: ProgressManager(prefix: config.progressPrefix))
        _bridge = StateObject(wrappedValue: GameDataBridge(
            gameId: config.gameId,
            starterDex: config.starterDex,
            context: nil // Core Data disabled — uses legacy GameData fallback
        ))
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
        }
    }
}
