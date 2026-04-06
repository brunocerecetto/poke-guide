//
//  PokemonGuideApp.swift
//  PokemonGuide
//
//  Created by Bruno Cerecetto on 6/4/26.
//

import SwiftUI

@main
struct PokemonGuideApp: App {
    @StateObject private var progress = ProgressManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progress)
        }
    }
}
