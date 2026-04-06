//
//  pokemon_guideApp.swift
//  pokemon guide
//
//  Created by Bruno Cerecetto on 6/4/26.
//

import SwiftUI

@main
struct pokemon_guideApp: App {
    @StateObject private var progress = ProgressManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progress)
        }
    }
}
