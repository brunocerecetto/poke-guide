//
//  RivalView.swift
//  PokemonGuide
//
//  Vista del rastreador de encuentros con el rival.
//

import SwiftUI

struct RivalView: View {
    @EnvironmentObject var gameConfig: GameConfig
    @EnvironmentObject var progress: ProgressManager
    @Environment(\.themeColors) private var theme

    var body: some View {
        ZStack {
            Color.fireBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    rivalHeader
                        .padding(.horizontal)
                        .padding(.top, 8)

                    ForEach(RivalData.encounters) { encounter in
                        RivalEncounterCard(
                            encounter: encounter,
                            starter: gameConfig.starter
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Rival")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.automatic, for: .navigationBar)
    }

    // MARK: - Header

    private var rivalHeader: some View {
        let rivalStarter = RivalData.rivalStarter(for: gameConfig.starter)
        return HStack(spacing: 12) {
            AsyncImage(url: rivalStarter.spriteURL) { image in
                image.interpolation(.none).resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text("Starter del rival")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1)
                Text(rivalStarter.displayName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.fireTextPrimary)
            }

            Spacer()

            // Encounter count
            let completed = RivalData.encounters.filter {
                progress.isRouteStepCompleted($0.id)
            }.count
            Text("\(completed)/\(RivalData.encounters.count)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(theme.accent)
        }
        .padding(14)
        .softCard(cornerRadius: 16)
    }
}

// MARK: - Encounter Card

private struct RivalEncounterCard: View {
    let encounter: RivalEncounter
    let starter: Starter

    @EnvironmentObject var progress: ProgressManager
    @Environment(\.themeColors) private var theme
    @State private var isExpanded = false

    private var team: [RivalPokemon] { encounter.team(starter) }
    private var isCompleted: Bool { progress.isRouteStepCompleted(encounter.id) }

    var body: some View {
        VStack(spacing: 0) {
            // Header row — always visible
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                headerContent
            }
            .buttonStyle(.plain)

            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .softCard(cornerRadius: 16)
    }

    // MARK: - Header

    private var headerContent: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                // Check toggle
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        progress.toggleRouteStep(encounter.id)
                    }
                } label: {
                    AnimatedCheck(isCompleted: isCompleted, size: 22)
                }

                Image(systemName: encounter.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.accent)

                Text(encounter.location)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(isCompleted ? .fireTextSecondary : .fireTextPrimary)
                    .strikethrough(isCompleted, color: .fireTextSecondary)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.fireTextSecondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }

            // Sprite row (compact preview)
            HStack(spacing: 6) {
                ForEach(team) { pokemon in
                    AsyncImage(url: pokemon.spriteURL) { image in
                        image.interpolation(.none).resizable().scaledToFit()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.fireCardAlt)
                            .frame(width: 36, height: 36)
                    }
                    .frame(width: 36, height: 36)
                }
                Spacer()
            }
        }
        .padding(14)
    }

    // MARK: - Expanded detail

    private var expandedContent: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.fireTextSecondary.opacity(0.15))

            VStack(spacing: 8) {
                ForEach(team) { pokemon in
                    pokemonRow(pokemon)
                }
            }
            .padding(14)
        }
    }

    private func pokemonRow(_ pokemon: RivalPokemon) -> some View {
        HStack(spacing: 10) {
            AsyncImage(url: pokemon.spriteURL) { image in
                image.interpolation(.none).resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(pokemon.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.fireTextPrimary)
                Text("Nv. \(pokemon.level)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
            }

            Spacer()

            Text("#\(pokemon.dexNumber)")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.fireTextSecondary.opacity(0.6))
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RivalView()
            .environmentObject(GameConfig())
            .environmentObject(ProgressManager())
    }
}
