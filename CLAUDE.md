# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A SwiftUI iOS app — a multi-game Pokémon walkthrough/guide with progress tracking. Supports 22+ games (Gen I–IX). UI is in Spanish. Built with Xcode, no external dependencies.

## Build & Run

Open `PokeGuide.xcodeproj` in Xcode and build (Cmd+B) / run (Cmd+R). No package managers or build scripts — pure Xcode project.

```bash
# Build from CLI
xcodebuild -project "PokeGuide.xcodeproj" -scheme "PokeGuide" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run tests
xcodebuild -project "PokeGuide.xcodeproj" -scheme "PokeGuide" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Architecture

- **Entry point**: `PokeGuideApp.swift` — injects `ProgressManager` as `@EnvironmentObject`
- **ProgressManager** (`ProgressManager.swift`): `ObservableObject` that persists all checklist progress to `UserDefaults`. Tracks gyms, route steps, league, pre-league, postgame (as `Set<String>`), and Pokédex statuses (as `[Int: PokemonStatus]`). Passed via `.environmentObject()` throughout the app.
- **GameData** (`GameData.swift`): All static game data — model structs (`Gym`, `TeamMember`, `Capture`, `RouteStep`, etc.) and static arrays/methods on `GameData`.
- **PokedexData** (`PokedexData.swift`): 151 Kanto Pokémon entries with types, stats, and locations (rich hardcoded data). Defines `PokemonType` enum and `PokemonStatus` enum.
- **PokemonLoader** (`PokemonLoader.swift`): Loads Pokémon from bundled `national_dex_gen*.json` files (1025 Pokémon, Gen I–IX). Returns game-specific entries filtered by `nationalDexMax`. Falls back to `PokedexData.kanto` for Gen 1 games.
- **GameListView** (`GameListView.swift`): Game catalog (`GameCatalogEntry`) with 22+ games. Each entry has `nationalDexMax` to determine its Pokédex scope.
- **Theme** (`Theme.swift`): FireRed color palette (`Color` extensions: `.fireRed`, `.fireBlue`, `.fireGreen`, etc.), reusable view modifiers (`softCard`, `glowText`), and shared components (`AnimatedCheck`, `PokeballProgress`, `TypeBadge`, `ConfettiView`, `FireRedCard`).
- **ContentView** (`ContentView.swift`): Main hub with navigation grid linking to all sections.

### Views

Each section is a standalone SwiftUI view reading from `ProgressManager` and `GameData`:
`GymView`, `TeamView`, `RouteView`, `PokedexView`, `PokedexDetailView`, `CapturesView`, `HMTMView`, `TipsView`, `LeagueView`.

`PixelBackground.swift` provides the warm cream background pattern.

## Conventions

- UI strings are in **Spanish**
- Light-mode-only design with the FireRed color palette from `Theme.swift`
- Use `softCard()` modifier for card-style containers
- Progress toggles follow the pattern: `progress.toggle*(id)` / `progress.is*Completed(id)`
