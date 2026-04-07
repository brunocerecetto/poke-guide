//
//  PokedexView.swift
//  poke guide
//
//  Pokédex interactivo — light mode.
//

import SwiftUI

struct PokedexView: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var gameConfig: GameConfig
    @Environment(\.themeColors) private var theme
    @State private var searchText = ""
    @State private var selectedType: PokemonType? = nil
    @State private var selectedStatus: PokemonStatus? = nil

    private var pokedexEntries: [PokemonEntry] {
        PokemonLoader.entries(forGameId: gameConfig.gameId)
    }

    private var filteredPokemon: [PokemonEntry] {
        pokedexEntries.filter { entry in
            let matchesSearch = searchText.isEmpty
                || entry.name.localizedCaseInsensitiveContains(searchText)
                || entry.dexString.contains(searchText)
            let matchesType = selectedType == nil || entry.types.contains(selectedType!)
            let matchesStatus = selectedStatus == nil || progress.pokemonStatus(for: entry.id) == selectedStatus!
            return matchesSearch && matchesType && matchesStatus
        }
    }

    private var caughtCount: Int {
        pokedexEntries.filter { progress.pokemonStatus(for: $0.id).rawValue >= PokemonStatus.caught.rawValue }.count
    }
    private var evolvedCount: Int {
        pokedexEntries.filter { progress.pokemonStatus(for: $0.id) == .evolved }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            statsBar
            typeFilter
            statusFilter

            ScrollView {
                LazyVStack(spacing: KASpacing.sm) {
                    ForEach(filteredPokemon) { entry in
                        pokemonRow(entry)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle("Pokédex")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Buscar pokémon...")
    }

    private var statsBar: some View {
        HStack(spacing: KASpacing.md) {
            statBubble(value: "\(caughtCount)", label: "Capturados", color: .primaryContainer)
            statBubble(value: "\(evolvedCount)", label: "Evolucionados", color: .success)
            statBubble(value: "\(pokedexEntries.count)", label: "Total", color: .onSurfaceVariant)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, KASpacing.md)
        .softCard(cornerRadius: KARadius.lg)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private func statBubble(value: String, label: String, color: Color) -> some View {
        VStack(spacing: KASpacing.xs) {
            Text(value)
                .font(KATypography.headlineMd)
                .foregroundColor(color)
            Text(label)
                .font(KATypography.labelXs)
                .foregroundColor(.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }

    private var typeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                chip(label: "Todos", isSelected: selectedType == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedType = nil }
                }
                ForEach(PokemonType.allCases, id: \.self) { type in
                    chip(label: type.rawValue.capitalized, icon: type.icon, color: type.color, isSelected: selectedType == type) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = selectedType == type ? nil : type
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
    }

    private var statusFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                chip(label: "Todos", isSelected: selectedStatus == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedStatus = nil }
                }
                ForEach(PokemonStatus.allCases, id: \.self) { status in
                    chip(label: status.label, icon: status.icon, color: status.color, isSelected: selectedStatus == status) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedStatus = selectedStatus == status ? nil : status
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
    }

    private func chip(label: String, icon: String? = nil, color: Color = .onSurfaceVariant, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: KASpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon).font(.system(size: 10))
                }
                Text(label).font(KATypography.labelSm)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(isSelected ? .onPrimary : color)
            .background(
                Capsule().fill(isSelected ? color : Color.surfaceContainerHighest)
            )
        }
        .buttonStyle(.plain)
    }

    private func pokemonRow(_ entry: PokemonEntry) -> some View {
        let status = progress.pokemonStatus(for: entry.id)
        let isAvailable = entry.isAvailable(in: gameConfig.version)

        return NavigationLink {
            PokedexDetailView(entry: entry)
        } label: {
            HStack(spacing: KASpacing.sm + KASpacing.xs) {
                AsyncImage(url: entry.spriteURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.interpolation(.none).resizable().scaledToFit().frame(width: 40, height: 40)
                            .saturation(isAvailable ? 1 : 0.3)
                    case .failure:
                        Image(systemName: status.icon).font(.system(size: 18)).foregroundColor(status.color)
                            .frame(width: 40, height: 40)
                    case .empty:
                        ProgressView().frame(width: 40, height: 40)
                    @unknown default: EmptyView()
                    }
                }
                .frame(width: 40, height: 40)

                Text(entry.dexString)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
                    .frame(width: 38, alignment: .leading)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Text(entry.name)
                            .font(KATypography.titleSm)
                            .foregroundColor(status == .notSeen ? .onSurfaceVariant : .onSurface)

                        if !isAvailable, let version = entry.availability {
                            Text(version == .fireRed ? "FR" : "LG")
                                .font(.system(size: 8, weight: .heavy, design: .rounded))
                                .foregroundColor(.onPrimary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(version.accentColor.opacity(0.7)))
                        }
                    }

                    HStack(spacing: KASpacing.xs) {
                        ForEach(entry.types, id: \.self) { type in
                            HStack(spacing: 2) {
                                Image(systemName: type.icon).font(.system(size: 8))
                                Text(type.rawValue.capitalized).font(KATypography.labelXs)
                            }
                            .foregroundColor(type.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(type.color.opacity(0.10)))
                        }
                    }
                }

                Spacer()

                Text(status.label)
                    .font(KATypography.labelXs)
                    .foregroundColor(status.color)
                    .padding(.horizontal, KASpacing.sm)
                    .padding(.vertical, KASpacing.xs)
                    .background(Capsule().fill(status.color.opacity(0.10)))

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.outlineVariant)
            }
            .padding(10)
            .softCard(cornerRadius: KARadius.lg, tint: status == .notSeen ? .clear : status.color)
            .opacity(isAvailable ? (status == .notSeen ? 0.6 : 1) : 0.45)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PokedexView()
            .environmentObject(ProgressManager())
            .environmentObject(GameConfig())
    }
}
