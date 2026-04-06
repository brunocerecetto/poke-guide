//
//  PokedexView.swift
//  pokemon guide
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

    private var filteredPokemon: [PokemonEntry] {
        PokedexData.kanto.filter { entry in
            let matchesSearch = searchText.isEmpty
                || entry.name.localizedCaseInsensitiveContains(searchText)
                || entry.dexString.contains(searchText)
            let matchesType = selectedType == nil || entry.types.contains(selectedType!)
            let matchesStatus = selectedStatus == nil || progress.pokemonStatus(for: entry.id) == selectedStatus!
            return matchesSearch && matchesType && matchesStatus
        }
    }

    private var caughtCount: Int {
        PokedexData.kanto.filter { progress.pokemonStatus(for: $0.id).rawValue >= PokemonStatus.caught.rawValue }.count
    }
    private var evolvedCount: Int {
        PokedexData.kanto.filter { progress.pokemonStatus(for: $0.id) == .evolved }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            statsBar
            typeFilter
            statusFilter

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredPokemon) { entry in
                        pokemonRow(entry)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .background(Color.fireBg.ignoresSafeArea())
        .navigationTitle("Pokédex")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Buscar pokémon...")
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: 16) {
            statBubble(value: "\(caughtCount)", label: "Capturados", color: .fireOrange)
            statBubble(value: "\(evolvedCount)", label: "Evolucionados", color: .fireGreen)
            statBubble(value: "\(PokedexData.kanto.count)", label: "Total", color: .fireTextSecondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .softCard(cornerRadius: 16, shadowRadius: 6)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private func statBubble(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.fireTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Type Filter

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

    // MARK: - Status Filter

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

    // MARK: - Chip

    private func chip(label: String, icon: String? = nil, color: Color = .fireTextSecondary, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon).font(.system(size: 10))
                }
                Text(label).font(.system(size: 11, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(isSelected ? .white : color)
            .background(
                Capsule().fill(isSelected ? color : Color.black.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pokemon Row

    private func pokemonRow(_ entry: PokemonEntry) -> some View {
        let status = progress.pokemonStatus(for: entry.id)
        let isAvailable = entry.isAvailable(in: gameConfig.version)

        return NavigationLink {
            PokedexDetailView(entry: entry)
        } label: {
            HStack(spacing: 12) {
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
                    .foregroundColor(.fireTextSecondary)
                    .frame(width: 38, alignment: .leading)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Text(entry.name)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(status == .notSeen ? .fireTextSecondary : .fireTextPrimary)

                        if !isAvailable, let version = entry.availability {
                            Text(version == .fireRed ? "FR" : "LG")
                                .font(.system(size: 8, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(version.accentColor.opacity(0.7)))
                        }
                    }

                    HStack(spacing: 4) {
                        ForEach(entry.types, id: \.self) { type in
                            HStack(spacing: 2) {
                                Image(systemName: type.icon).font(.system(size: 8))
                                Text(type.rawValue.capitalized).font(.system(size: 9, weight: .medium, design: .rounded))
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
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(status.color.opacity(0.10)))

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.black.opacity(0.15))
            }
            .padding(10)
            .softCard(cornerRadius: 14, tint: status == .notSeen ? .clear : status.color, shadowRadius: 4)
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
