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
    @State private var showFilterSheet = false

    @AppStorage("pokedex_sort") private var sortRaw: String = PokedexSort.dexNumber.rawValue
    @AppStorage("pokedex_type") private var typeRaw: String = ""
    @AppStorage("pokedex_status") private var statusRaw: Int = -1
    @AppStorage("pokedex_grid") private var showGrid: Bool = false

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
            filterBar

            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 0) {
                        if showGrid {
                            LazyVGrid(
                                columns: [GridItem(.adaptive(minimum: 100), spacing: KASpacing.sm)],
                                spacing: KASpacing.sm
                            ) {
                                ForEach(filteredPokemon) { entry in
                                    pokemonGridCell(entry)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: KASpacing.sm) {
                                ForEach(filteredPokemon) { entry in
                                    pokemonRow(entry)
                                }
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 0)

                        FanDisclaimer()
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle("Pokédex")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Buscar pokémon...")
        .sheet(isPresented: $showFilterSheet) {
            PokedexFilterSheet(typeRaw: $typeRaw, statusRaw: $statusRaw)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var statsBar: some View {
        HStack(spacing: KASpacing.md) {
            statBubble(value: "\(caughtCount)", label: "Capturados", color: theme.secondary)
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

    private var hasActiveFilters: Bool {
        selectedType != nil || selectedStatus != nil
    }

    private var filterBar: some View {
        HStack(spacing: KASpacing.sm) {
            // Filter button
            Button { showFilterSheet = true } label: {
                toolbarCapsule(
                    icon: "line.3.horizontal.decrease",
                    label: "Filtro",
                    accent: hasActiveFilters ? theme.secondary : nil
                )
            }
            .buttonStyle(.plain)

            Spacer()

            // View toggle
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showGrid.toggle() }
            } label: {
                toolbarCapsule(
                    icon: showGrid ? "square.grid.2x2.fill" : "list.bullet",
                    label: showGrid ? "Grilla" : "Lista"
                )
            }
            .buttonStyle(.plain)

            // Sort menu
            Menu {
                ForEach(PokedexSort.allCases, id: \.self) { sort in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { sortRaw = sort.rawValue }
                    } label: {
                        Label(sort.rawValue, systemImage: selectedSort == sort ? "checkmark" : sort.icon)
                    }
                }
            } label: {
                toolbarCapsule(
                    icon: selectedSort.icon,
                    label: selectedSort.rawValue,
                    showChevron: true
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func toolbarCapsule(
        icon: String,
        label: String,
        accent: Color? = nil,
        showChevron: Bool = false
    ) -> some View {
        HStack(spacing: KASpacing.xs) {
            Image(systemName: icon).font(.system(size: 10))
            Text(label).font(KATypography.labelSm)
            if showChevron {
                Image(systemName: "chevron.down").font(.system(size: 8, weight: .bold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .foregroundColor(accent ?? .onSurfaceVariant)
        .background(
            Capsule().fill(accent != nil ? accent!.opacity(0.10) : Color.surfaceContainerHighest)
        )
    }

    private func pokemonRow(_ entry: PokemonEntry) -> some View {
        let status = progress.pokemonStatus(for: entry.id)
        let isAvailable = entry.isAvailable(in: gameConfig.version)

        return NavigationLink {
            PokedexDetailView(entry: entry)
        } label: {
            HStack(spacing: KASpacing.sm + KASpacing.xs) {
                if status == .notSeen {
                    ZStack {
                        Circle()
                            .fill(Color.surfaceContainerHighest)
                            .frame(width: 40, height: 40)
                        Image(systemName: "questionmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.onSurfaceVariant.opacity(0.4))
                    }
                } else {
                    CachedSpriteView(url: entry.spriteURL, size: 40)
                        .saturation(isAvailable ? 1 : 0.3)
                }

                Text(entry.dexString)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
                    .frame(width: 38, alignment: .leading)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Text(entry.name)
                            .font(KATypography.titleSm)
                            .foregroundColor(.onSurface)

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

                Menu {
                    ForEach(PokemonStatus.allCases, id: \.self) { option in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                progress.setPokemonStatus(for: entry.id, to: option)
                            }
                        } label: {
                            Label(option.label, systemImage: option.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: status.icon)
                            .font(.system(size: 10))
                        Text(status.label)
                            .font(KATypography.labelXs)
                    }
                    .foregroundColor(status.color)
                    .padding(.horizontal, KASpacing.sm)
                    .padding(.vertical, KASpacing.xs)
                    .background(Capsule().fill(status.color.opacity(0.10)))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.outlineVariant)
            }
            .padding(10)
            .softCard(cornerRadius: KARadius.lg, tint: status == .notSeen ? .clear : status.color)
            .opacity(isAvailable ? 1 : 0.45)
        }
        .buttonStyle(.plain)
    }

    private func pokemonGridCell(_ entry: PokemonEntry) -> some View {
        let status = progress.pokemonStatus(for: entry.id)
        let isAvailable = entry.isAvailable(in: gameConfig.version)

        return NavigationLink {
            PokedexDetailView(entry: entry)
        } label: {
            VStack(spacing: KASpacing.xs) {
                if status == .notSeen {
                    ZStack {
                        Circle()
                            .fill(Color.surfaceContainerHighest)
                            .frame(width: 56, height: 56)
                        Image(systemName: "questionmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.onSurfaceVariant.opacity(0.4))
                    }
                } else {
                    CachedSpriteView(url: entry.spriteURL, size: 56)
                        .saturation(isAvailable ? 1 : 0.3)
                }

                Text(entry.dexString)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)

                Text(entry.name)
                    .font(KATypography.labelSm)
                    .foregroundColor(.onSurface)
                    .lineLimit(1)

                Menu {
                    ForEach(PokemonStatus.allCases, id: \.self) { option in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                progress.setPokemonStatus(for: entry.id, to: option)
                            }
                        } label: {
                            Label(option.label, systemImage: option.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: status.icon)
                            .font(.system(size: 9))
                        Text(status.label)
                            .font(KATypography.labelXs)
                    }
                    .foregroundColor(status.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(status.color.opacity(0.10)))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, KASpacing.sm)
            .padding(.horizontal, KASpacing.xs)
            .softCard(cornerRadius: KARadius.lg, tint: status == .notSeen ? .clear : status.color)
            .opacity(isAvailable ? 1 : 0.45)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter Sheet

struct PokedexFilterSheet: View {
    @Binding var typeRaw: String
    @Binding var statusRaw: Int
    @Environment(\.dismiss) private var dismiss

    private var selectedType: PokemonType? {
        typeRaw.isEmpty ? nil : PokemonType(rawValue: typeRaw)
    }

    private var selectedStatus: PokemonStatus? {
        statusRaw < 0 ? nil : PokemonStatus(rawValue: statusRaw)
    }

    private var hasFilters: Bool {
        selectedType != nil || selectedStatus != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: KASpacing.lg) {
                    // Type section
                    VStack(alignment: .leading, spacing: KASpacing.sm) {
                        Text("Tipo")
                            .font(KATypography.titleSm)
                            .foregroundColor(.onSurface)

                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 90), spacing: KASpacing.sm)],
                            spacing: KASpacing.sm
                        ) {
                            ForEach(PokemonType.allCases, id: \.self) { type in
                                let isSelected = selectedType == type
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        typeRaw = isSelected ? "" : type.rawValue
                                    }
                                } label: {
                                    HStack(spacing: KASpacing.xs) {
                                        Image(systemName: type.icon)
                                            .font(.system(size: 10))
                                        Text(type.rawValue.capitalized)
                                            .font(KATypography.labelSm)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .foregroundColor(isSelected ? .onPrimary : type.color)
                                    .background(
                                        RoundedRectangle(cornerRadius: KARadius.sm)
                                            .fill(isSelected ? type.color : type.color.opacity(0.10))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Status section
                    VStack(alignment: .leading, spacing: KASpacing.sm) {
                        Text("Estado")
                            .font(KATypography.titleSm)
                            .foregroundColor(.onSurface)

                        HStack(spacing: KASpacing.sm) {
                            ForEach(PokemonStatus.allCases, id: \.self) { status in
                                let isSelected = selectedStatus == status
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        statusRaw = isSelected ? -1 : status.rawValue
                                    }
                                } label: {
                                    VStack(spacing: KASpacing.xs) {
                                        Image(systemName: status.icon)
                                            .font(.system(size: 16, weight: .semibold))
                                        Text(status.label)
                                            .font(KATypography.labelXs)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, KASpacing.sm)
                                    .foregroundColor(isSelected ? .onPrimary : status.color)
                                    .background(
                                        RoundedRectangle(cornerRadius: KARadius.sm)
                                            .fill(isSelected ? status.color : status.color.opacity(0.10))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.surface.ignoresSafeArea())
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if hasFilters {
                        Button("Limpiar") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                typeRaw = ""
                                statusRaw = -1
                            }
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PokedexView()
            .environmentObject(ProgressManager())
            .environmentObject(GameConfig())
    }
}
