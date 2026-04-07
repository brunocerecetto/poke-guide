//
//  GameListView.swift
//  PokeGuide
//
//  Catálogo de juegos Pokémon agrupados por generación.
//

import SwiftUI

// MARK: - Game Catalog Model

struct GameCatalogEntry: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let generation: Int
    let region: String
    let releaseYear: Int
    let platform: String
    let accentHex: String
    let secondaryHex: String
    let icon: String
    let starters: [Int]
    let gymCount: Int
    let hasEliteFour: Bool
    let nationalDexMax: Int

    var accentColor: Color { Color(hex: accentHex) }
    var secondaryColor: Color { Color(hex: secondaryHex) }
}

// MARK: - Game Catalog Data

extension GameCatalogEntry {
    static let allGames: [GameCatalogEntry] = [
        GameCatalogEntry(id: "red", name: "Pokémon Red", generation: 1, region: "Kanto", releaseYear: 1996, platform: "GB", accentHex: "#E02D28", secondaryHex: "#F06040", icon: "flame.fill", starters: [1, 4, 7], gymCount: 8, hasEliteFour: true, nationalDexMax: 151),
        GameCatalogEntry(id: "blue", name: "Pokémon Blue", generation: 1, region: "Kanto", releaseYear: 1996, platform: "GB", accentHex: "#2266CC", secondaryHex: "#4488EE", icon: "drop.fill", starters: [1, 4, 7], gymCount: 8, hasEliteFour: true, nationalDexMax: 151),
        GameCatalogEntry(id: "yellow", name: "Pokémon Yellow", generation: 1, region: "Kanto", releaseYear: 1998, platform: "GB", accentHex: "#DAA520", secondaryHex: "#F0C040", icon: "bolt.fill", starters: [25], gymCount: 8, hasEliteFour: true, nationalDexMax: 151),
        GameCatalogEntry(id: "firered", name: "Pokémon FireRed", generation: 1, region: "Kanto", releaseYear: 2004, platform: "GBA", accentHex: "#E02D28", secondaryHex: "#F06040", icon: "flame.fill", starters: [1, 4, 7], gymCount: 8, hasEliteFour: true, nationalDexMax: 151),
        GameCatalogEntry(id: "leafgreen", name: "Pokémon LeafGreen", generation: 1, region: "Kanto", releaseYear: 2004, platform: "GBA", accentHex: "#2EAA52", secondaryHex: "#40CC70", icon: "leaf.fill", starters: [1, 4, 7], gymCount: 8, hasEliteFour: true, nationalDexMax: 151),
        GameCatalogEntry(id: "gold", name: "Pokémon Gold", generation: 2, region: "Johto", releaseYear: 1999, platform: "GBC", accentHex: "#DAA520", secondaryHex: "#F0C040", icon: "sun.max.fill", starters: [152, 155, 158], gymCount: 16, hasEliteFour: true, nationalDexMax: 251),
        GameCatalogEntry(id: "silver", name: "Pokémon Silver", generation: 2, region: "Johto", releaseYear: 1999, platform: "GBC", accentHex: "#AAAACC", secondaryHex: "#C0C0E0", icon: "moon.fill", starters: [152, 155, 158], gymCount: 16, hasEliteFour: true, nationalDexMax: 251),
        GameCatalogEntry(id: "crystal", name: "Pokémon Crystal", generation: 2, region: "Johto", releaseYear: 2000, platform: "GBC", accentHex: "#5B9BD5", secondaryHex: "#80C0F0", icon: "diamond.fill", starters: [152, 155, 158], gymCount: 16, hasEliteFour: true, nationalDexMax: 251),
        GameCatalogEntry(id: "ruby", name: "Pokémon Ruby", generation: 3, region: "Hoenn", releaseYear: 2002, platform: "GBA", accentHex: "#A80000", secondaryHex: "#D03030", icon: "diamond.fill", starters: [252, 255, 258], gymCount: 8, hasEliteFour: true, nationalDexMax: 386),
        GameCatalogEntry(id: "sapphire", name: "Pokémon Sapphire", generation: 3, region: "Hoenn", releaseYear: 2002, platform: "GBA", accentHex: "#0044AA", secondaryHex: "#2266CC", icon: "drop.fill", starters: [252, 255, 258], gymCount: 8, hasEliteFour: true, nationalDexMax: 386),
        GameCatalogEntry(id: "emerald", name: "Pokémon Emerald", generation: 3, region: "Hoenn", releaseYear: 2004, platform: "GBA", accentHex: "#009955", secondaryHex: "#30BB70", icon: "sparkles", starters: [252, 255, 258], gymCount: 8, hasEliteFour: true, nationalDexMax: 386),
        GameCatalogEntry(id: "diamond", name: "Pokémon Diamond", generation: 4, region: "Sinnoh", releaseYear: 2006, platform: "DS", accentHex: "#6688CC", secondaryHex: "#88AAEE", icon: "diamond.fill", starters: [387, 390, 393], gymCount: 8, hasEliteFour: true, nationalDexMax: 493),
        GameCatalogEntry(id: "pearl", name: "Pokémon Pearl", generation: 4, region: "Sinnoh", releaseYear: 2006, platform: "DS", accentHex: "#CC6688", secondaryHex: "#EE88AA", icon: "circle.fill", starters: [387, 390, 393], gymCount: 8, hasEliteFour: true, nationalDexMax: 493),
        GameCatalogEntry(id: "black", name: "Pokémon Black", generation: 5, region: "Unova", releaseYear: 2010, platform: "DS", accentHex: "#333333", secondaryHex: "#555555", icon: "circle.lefthalf.filled", starters: [495, 498, 501], gymCount: 8, hasEliteFour: true, nationalDexMax: 649),
        GameCatalogEntry(id: "white", name: "Pokémon White", generation: 5, region: "Unova", releaseYear: 2010, platform: "DS", accentHex: "#E8E8E8", secondaryHex: "#CCCCCC", icon: "circle.righthalf.filled", starters: [495, 498, 501], gymCount: 8, hasEliteFour: true, nationalDexMax: 649),
        GameCatalogEntry(id: "x", name: "Pokémon X", generation: 6, region: "Kalos", releaseYear: 2013, platform: "3DS", accentHex: "#0055AA", secondaryHex: "#2277CC", icon: "xmark", starters: [650, 653, 656], gymCount: 8, hasEliteFour: true, nationalDexMax: 721),
        GameCatalogEntry(id: "y", name: "Pokémon Y", generation: 6, region: "Kalos", releaseYear: 2013, platform: "3DS", accentHex: "#CC0033", secondaryHex: "#EE2255", icon: "yensign", starters: [650, 653, 656], gymCount: 8, hasEliteFour: true, nationalDexMax: 721),
        GameCatalogEntry(id: "sun", name: "Pokémon Sun", generation: 7, region: "Alola", releaseYear: 2016, platform: "3DS", accentHex: "#FF8800", secondaryHex: "#FFAA30", icon: "sun.max.fill", starters: [722, 725, 728], gymCount: 0, hasEliteFour: true, nationalDexMax: 809),
        GameCatalogEntry(id: "moon", name: "Pokémon Moon", generation: 7, region: "Alola", releaseYear: 2016, platform: "3DS", accentHex: "#5544AA", secondaryHex: "#7766CC", icon: "moon.fill", starters: [722, 725, 728], gymCount: 0, hasEliteFour: true, nationalDexMax: 809),
        GameCatalogEntry(id: "sword", name: "Pokémon Sword", generation: 8, region: "Galar", releaseYear: 2019, platform: "Switch", accentHex: "#0077BB", secondaryHex: "#2299DD", icon: "shield.lefthalf.filled", starters: [810, 813, 816], gymCount: 8, hasEliteFour: true, nationalDexMax: 905),
        GameCatalogEntry(id: "shield", name: "Pokémon Shield", generation: 8, region: "Galar", releaseYear: 2019, platform: "Switch", accentHex: "#BB0044", secondaryHex: "#DD2266", icon: "shield.righthalf.filled", starters: [810, 813, 816], gymCount: 8, hasEliteFour: true, nationalDexMax: 905),
        GameCatalogEntry(id: "scarlet", name: "Pokémon Scarlet", generation: 9, region: "Paldea", releaseYear: 2022, platform: "Switch", accentHex: "#CC2200", secondaryHex: "#EE4422", icon: "book.fill", starters: [906, 909, 912], gymCount: 8, hasEliteFour: true, nationalDexMax: 1025),
        GameCatalogEntry(id: "violet", name: "Pokémon Violet", generation: 9, region: "Paldea", releaseYear: 2022, platform: "Switch", accentHex: "#7722CC", secondaryHex: "#9944EE", icon: "book.closed.fill", starters: [906, 909, 912], gymCount: 8, hasEliteFour: true, nationalDexMax: 1025),
    ]

    static let savedProgress: [String: Double] = [:]

    static var generations: [Int] {
        Array(Set(allGames.map(\.generation))).sorted()
    }

    static func games(for generation: Int) -> [GameCatalogEntry] {
        allGames.filter { $0.generation == generation }
    }

    static let generationNames: [Int: String] = [
        1: "Generación I", 2: "Generación II", 3: "Generación III",
        4: "Generación IV", 5: "Generación V", 6: "Generación VI",
        7: "Generación VII", 8: "Generación VIII", 9: "Generación IX",
    ]
}

// MARK: - Game List View

struct GameListView: View {
    @State private var searchText = ""
    @State private var appeared = false
    @State private var selectedGame: GameCatalogEntry?
    @State private var expandedGeneration: Int? = 1

    private var filteredGames: [GameCatalogEntry] {
        guard !searchText.isEmpty else { return GameCatalogEntry.allGames }
        let query = searchText.lowercased()
        return GameCatalogEntry.allGames.filter {
            $0.name.lowercased().contains(query) || $0.region.lowercased().contains(query)
        }
    }

    private var filteredGenerations: [Int] {
        let games = filteredGames
        return Array(Set(games.map(\.generation))).sorted()
    }

    var body: some View {
        NavigationStack {
            PageLayout(background: .clear) {
                VStack(spacing: KASpacing.lg) {
                    titleHeader
                        .padding(.top, KASpacing.md)

                    searchBar
                        .padding(.horizontal)

                    ForEach(Array(filteredGenerations.enumerated()), id: \.element) { index, gen in
                        generationSection(gen: gen, index: index)
                    }
                }
            }
            .background(PixelBackground())
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedGame) { game in
                StarterPickerView(game: game)
            }
        }
    }

    private var titleHeader: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "sparkle")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.primaryContainer)
                    .symbolEffect(.pulse, options: .repeating)

                Text("POKÉMON GUIDE")
                    .font(KATypography.labelSm)
                    .foregroundColor(.onSurfaceVariant)
                    .tracking(4)

                Image(systemName: "sparkle")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.primaryContainer)
                    .symbolEffect(.pulse, options: .repeating)
            }

            Text("Elegí tu juego")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.onSurface)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -15)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    // Input field: surfaceContainerHighest bg, no border
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.onSurfaceVariant)

            TextField("Buscar juego o región...", text: $searchText)
                .font(KATypography.bodyMd)
                .foregroundColor(.onSurface)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurfaceVariant.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, KASpacing.md)
        .padding(.vertical, KASpacing.sm + 3)
        .background(
            RoundedRectangle(cornerRadius: KARadius.md)
                .fill(Color.surfaceContainerHighest)
        )
    }

    private func generationSection(gen: Int, index: Int) -> some View {
        let games = filteredGames.filter { $0.generation == gen }
        let isExpanded = expandedGeneration == gen

        return VStack(alignment: .leading, spacing: KASpacing.sm + KASpacing.xs) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    expandedGeneration = isExpanded ? nil : gen
                }
            } label: {
                HStack(spacing: KASpacing.sm) {
                    Text(GameCatalogEntry.generationNames[gen] ?? "Gen \(gen)")
                        .font(KATypography.titleMd)
                        .foregroundColor(.onSurface)

                    if !isExpanded {
                        HStack(spacing: 6) {
                            ForEach(games) { game in
                                Image(systemName: game.icon)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(game.accentColor.opacity(gen == 1 ? 1 : 0.5))
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.onSurfaceVariant)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .padding(.horizontal)

            if isExpanded {
                let columns = [
                    GridItem(.flexible(), spacing: KASpacing.md),
                    GridItem(.flexible(), spacing: KASpacing.md),
                ]

                LazyVGrid(columns: columns, spacing: KASpacing.md) {
                    ForEach(games) { game in
                        gameCard(game: game)
                            .onTapGesture {
                                guard game.generation == 1 else { return }
                                selectedGame = game
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, KASpacing.xs)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 25)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(0.1 + Double(index) * 0.06),
            value: appeared
        )
    }

    private func gameCard(game: GameCatalogEntry) -> some View {
        let progress = GameCatalogEntry.savedProgress[game.id]

        return VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: KARadius.sm)
                    .fill(game.accentColor.opacity(0.10))
                    .frame(width: 52, height: 52)

                Image(systemName: game.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(game.accentColor)
            }

            Text(game.name)
                .font(KATypography.titleSm)
                .foregroundColor(.onSurface)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            HStack(spacing: KASpacing.xs) {
                Text(game.region)
                    .font(KATypography.labelSm)
                    .foregroundColor(.onSurfaceVariant)

                Text("·")
                    .font(KATypography.labelSm)
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))

                Text(game.platform)
                    .font(KATypography.labelSm)
                    .foregroundColor(game.accentColor.opacity(0.8))
            }

            if game.generation != 1 {
                HStack(spacing: KASpacing.xs) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                    Text("Próximamente")
                        .font(KATypography.labelSm)
                }
                .foregroundColor(.onSurfaceVariant.opacity(0.6))
            } else if let progress {
                HStack(spacing: 5) {
                    ProgressView(value: progress)
                        .tint(game.accentColor)
                        .scaleEffect(y: 1.5)

                    Text("\(Int(progress * 100))%")
                        .font(KATypography.labelXs)
                        .foregroundColor(game.accentColor)
                }
            } else {
                HStack(spacing: KASpacing.xs) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 11))
                    Text("Nuevo")
                        .font(KATypography.labelSm)
                }
                .foregroundColor(.onSurfaceVariant.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg, tint: game.generation == 1 ? game.accentColor : .gray)
        .opacity(game.generation == 1 ? 1.0 : 0.55)
    }
}

#Preview {
    GameListView()
}
