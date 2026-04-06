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
                    GameSelectionView()
                }
            }
            .environmentObject(gameConfig)
            .environmentObject(progress)
            .environment(\.themeColors, ThemeColors.forVersion(gameConfig.version))
        }
    }
}
