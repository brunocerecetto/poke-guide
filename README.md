# Pokemon FireRed Guide

A SwiftUI iOS app — a walkthrough/guide for Pokemon FireRed with progress tracking, optimized for a Squirtle starter run. UI is in Spanish.

## Features

- **Gym tracker** — 8 badges with completion checkmarks and confetti celebration
- **Team builder** — recommended 6-Pokemon team with movesets, evolution timelines, and TM priorities
- **Step-by-step route** — full walkthrough from Pallet Town to the Elite Four with toggleable progress
- **Pokedex** — all 151 Kanto Pokemon with stats, types, locations, and catch/evolve tracking
- **Key captures** — the 5 essential Pokemon to catch and where to find them
- **HMs & TMs** — which moves go on which Pokemon and where to get them
- **Tips** — evolution stone timing, money management, and item priorities
- **Elite Four plan** — exact strategies per member with a pre-league checklist

## Screenshots

Built with the FireRed color palette — warm cream backgrounds, soft cards, and Pokemon-themed accents.

## Requirements

- Xcode 16+
- iOS 18+

## Build & Run

Open `PokemonGuide.xcodeproj` in Xcode and press Cmd+R.

```bash
# CLI build
xcodebuild -project "PokemonGuide.xcodeproj" \
  -scheme "PokemonGuide" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

## Architecture

- **Entry point**: `pokemon_guideApp.swift` — injects `ProgressManager` as `@EnvironmentObject`
- **ProgressManager** — persists all checklist progress to `UserDefaults`
- **GameData** — static game data (gyms, team, routes, tips, Elite Four)
- **PokedexData** — 151 Kanto Pokemon with types, stats, and locations
- **Theme** — FireRed color palette, `softCard` modifier, reusable components

Each section (Gyms, Team, Route, Pokedex, Captures, HMs/TMs, Tips, League) is a standalone SwiftUI view.

## License

Personal project — not affiliated with Nintendo or The Pokemon Company.
