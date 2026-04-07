//
//  PokedexView.swift
//  poke guide
//
//  Pokédex interactivo — light mode.
//

import SwiftUI

enum PokedexSort: String, CaseIterable {
    case dexNumber = "Número"
    case name = "Nombre"
    case statTotal = "Stats"

    var icon: String {
        switch self {
        case .dexNumber: return "number"
        case .name: return "textformat.abc"
        case .statTotal: return "chart.bar.fill"
        }
    }
}

struct PokedexView: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var gameConfig: GameConfig
    @Environment(\.themeColors) private var theme
    @State private var searchText = ""

    @AppStorage("pokedex_sort") private var sortRaw: String = PokedexSort.dexNumber.rawValue
    @AppStorage("pokedex_type") private var typeRaw: String = ""
    @AppStorage("pokedex_status") private var statusRaw: Int = -1

    private var selectedSort: PokedexSort {
        PokedexSort(rawValue: sortRaw) ?? .dexNumber
    }

    private var selectedType: PokemonType? {
        typeRaw.isEmpty ? nil : PokemonType(rawValue: typeRaw)
    }

    private var selectedStatus: PokemonStatus? {
        statusRaw < 0 ? nil : PokemonStatus(rawValue: statusRaw)
    }

    private var pokedexEntries: [PokemonEntry] {
        PokemonLoader.entries(forGameId: gameConfig.gameId)
    }

    private var filteredPokemon: [PokemonEntry] {
        let filtered = pokedexEntries.filter { entry in
            let matchesSearch = searchText.isEmpty
                || entry.name.localizedCaseInsensitiveContains(searchText)
                || entry.dexString.contains(searchText)
            let matchesType = selectedType == nil || entry.types.contains(selectedType!)
            let matchesStatus = selectedStatus == nil || progress.pokemonStatus(for: entry.id) == selectedStatus!
            return matchesSearch && matchesType && matchesStatus
        }

        switch selectedSort {
        case .dexNumber:
            return filtered.sorted { $0.id < $1.id }
        case .name:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .statTotal:
            return filtered.sorted { $0.stats.total > $1.stats.total }
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
            sortFilter

            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 0) {
                        LazyVStack(spacing: KASpacing.sm) {
                            ForEach(filteredPokemon) { entry in
                                pokemonRow(entry)
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 0)

                        FanDisclaimer()
                    }
                    .frame(minHeight: geo.size.height)
                }
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
                    withAnimation(.easeInOut(duration: 0.2)) { typeRaw = "" }
                }
                ForEach(PokemonType.allCases, id: \.self) { type in
                    chip(label: type.rawValue.capitalized, icon: type.icon, color: type.color, isSelected: selectedType == type) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            typeRaw = selectedType == type ? "" : type.rawValue
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
                    withAnimation(.easeInOut(duration: 0.2)) { statusRaw = -1 }
                }
                ForEach(PokemonStatus.allCases, id: \.self) { status in
                    chip(label: status.label, icon: status.icon, color: status.color, isSelected: selectedStatus == status) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            statusRaw = selectedStatus == status ? -1 : status.rawValue
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
    }

    private var sortFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(PokedexSort.allCases, id: \.self) { sort in
                    chip(label: sort.rawValue, icon: sort.icon, isSelected: selectedSort == sort) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            sortRaw = sort.rawValue
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
                CachedSpriteView(url: entry.spriteURL, size: 40)
                    .saturation(isAvailable ? 1 : 0.3)

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
