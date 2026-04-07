//
//  RivalView.swift
//  PokeGuide
//
//  Vista del rastreador de encuentros con el rival.
//

import SwiftUI

struct RivalView: View {
    @EnvironmentObject var gameConfig: GameConfig
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme

    private var encounters: [RivalEncounterDTO] { bridge.rivalEncounters }

    var body: some View {
        ZStack {
            Color.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: KASpacing.md) {
                    rivalHeader
                        .padding(.horizontal)
                        .padding(.top, KASpacing.sm)

                    ForEach(encounters) { encounter in
                        RivalEncounterCard(encounter: encounter)
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

    private var rivalHeader: some View {
        let rivalStarter = RivalData.rivalStarter(for: gameConfig.starter)
        return HStack(spacing: KASpacing.sm + KASpacing.xs) {
            AsyncImage(url: rivalStarter.spriteURL) { image in
                image.interpolation(.none).resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text("Starter del rival")
                    .font(KATypography.labelSm)
                    .foregroundColor(.onSurfaceVariant)
                    .textCase(.uppercase)
                    .tracking(1)
                Text(rivalStarter.displayName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.onSurface)
            }

            Spacer()

            let completed = encounters.filter {
                progress.isRouteStepCompleted(bridge.rivalEncounterProgressId(for: $0))
            }.count
            Text("\(completed)/\(encounters.count)")
                .font(KATypography.titleSm)
                .foregroundColor(theme.accent)
        }
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg)
    }
}

private struct RivalEncounterCard: View {
    let encounter: RivalEncounterDTO

    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme
    @State private var isExpanded = false

    private var team: [RivalPokemonDTO] { encounter.team }
    private var encounterId: String { bridge.rivalEncounterProgressId(for: encounter) }
    private var isCompleted: Bool { progress.isRouteStepCompleted(encounterId) }

    var body: some View {
        VStack(spacing: 0) {
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
        .softCard(cornerRadius: KARadius.lg)
    }

    private var headerContent: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        progress.toggleRouteStep(encounterId)
                    }
                } label: {
                    AnimatedCheck(isCompleted: isCompleted, size: 22)
                }

                Image(systemName: encounter.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.accent)

                Text(encounter.location)
                    .font(KATypography.titleSm)
                    .foregroundColor(isCompleted ? .onSurfaceVariant : .onSurface)
                    .strikethrough(isCompleted, color: .onSurfaceVariant)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.onSurfaceVariant)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }

            HStack(spacing: 6) {
                ForEach(team) { pokemon in
                    AsyncImage(url: Self.spriteURL(dex: pokemon.dexNumber)) { image in
                        image.interpolation(.none).resizable().scaledToFit()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceContainerHigh)
                            .frame(width: 36, height: 36)
                    }
                    .frame(width: 36, height: 36)
                }
                Spacer()
            }
        }
        .padding(KASpacing.md)
    }

    private var expandedContent: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: KASpacing.sm)

            VStack(spacing: KASpacing.sm) {
                ForEach(team) { pokemon in
                    pokemonRow(pokemon)
                }
            }
            .padding(KASpacing.md)
        }
    }

    private static func spriteURL(dex: Int) -> URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(dex).png")
    }

    private func pokemonRow(_ pokemon: RivalPokemonDTO) -> some View {
        HStack(spacing: 10) {
            AsyncImage(url: Self.spriteURL(dex: pokemon.dexNumber)) { image in
                image.interpolation(.none).resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(pokemon.name)
                    .font(KATypography.titleSm)
                    .foregroundColor(.onSurface)
                Text("Nv. \(pokemon.level)")
                    .font(KATypography.bodySmall)
                    .foregroundColor(.onSurfaceVariant)
            }

            Spacer()

            Text("#\(pokemon.dexNumber)")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.6))
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        RivalView()
            .environmentObject(GameConfig())
            .environmentObject(ProgressManager())
            .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
    }
}
