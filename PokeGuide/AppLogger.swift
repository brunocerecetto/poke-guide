//
//  AppLogger.swift
//  PokeGuide
//
//  Structured logging via os.Logger for the app.
//

import Foundation
import os

enum AppLogger {
    static let coreData = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PokeGuide", category: "CoreData")
    static let guideRepo = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PokeGuide", category: "GuideRepository")
    static let pokemonRepo = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PokeGuide", category: "PokemonRepository")
    static let progress = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PokeGuide", category: "Progress")
    static let dataSeeder = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PokeGuide", category: "DataSeeder")
}
