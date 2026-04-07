//
//  TeamTab.swift
//  PokeGuide
//
//  Equipo tab — recommended team + my team + captures, all with sprite previews.
//

import SwiftUI

struct TeamTab: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var gameConfig: GameConfig
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme

    private var customTeam: [PokemonEntry?] {
        progress.customTeamEntries(gameId: gameConfig.gameId)
    }

    private var filledTeam: [PokemonEntry] {
        customTeam.compactMap { $0 }
    }

    var body: some View {
        NavigationStack {
            PageLayout(background: .clear) {
                VStack(spacing: KASpacing.lg) {
                    // Equipo Recomendado
                    recommendedSection
                        .padding(.horizontal)

                    // Mi Equipo
                    myTeamSection
                        .padding(.horizontal)

                    // Capturas Clave
                    capturesSection
                        .padding(.horizontal)
                }
                .padding(.top, KASpacing.sm + KASpacing.xs)
            }
            .background(PixelBackground())
            .navigationTitle("Equipo")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Equipo Recomendado

    private var recommendedSection: some View {
        NavigationLink {
            MyTeamDetailView(mode: .recommended(members: bridge.team))
        } label: {
            teamPreviewCard(
                icon: "star.fill",
                title: "Equipo Recomendado",
                count: bridge.team.count,
                sprites: bridge.team.map { (dexNumber: $0.dexNumber, emoji: $0.emoji) },
                hint: "Tocá para ver movesets + análisis"
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mi Equipo

    private var myTeamSection: some View {
        NavigationLink {
            MyTeamDetailView(mode: .custom)
        } label: {
            teamPreviewCard(
                icon: "hammer.fill",
                title: "Mi Equipo",
                count: filledTeam.count,
                sprites: (0..<6).map { i in
                    if let entry = i < customTeam.count ? customTeam[i] : nil {
                        return (dexNumber: entry.id, emoji: "")
                    }
                    return (dexNumber: 0, emoji: "")
                },
                hint: filledTeam.isEmpty ? "Tocá para armar tu equipo" : "Tocá para editar + ver análisis"
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Capturas Clave

    private var capturesSection: some View {
        NavigationLink {
            CapturesView()
        } label: {
            VStack(spacing: KASpacing.sm + KASpacing.xs) {
                HStack(spacing: 6) {
                    Image(systemName: "scope")
                        .foregroundColor(.success)
                    Text("Capturas Clave")
                        .font(KATypography.titleSm)
                        .foregroundColor(.success)
                    Spacer()
                    Text("\(bridge.captures.count)")
                        .font(KATypography.bodySmall)
                        .foregroundColor(.onSurfaceVariant)
                }

                let captureDexNumbers = bridge.captures.compactMap { captureDexNumber($0.pokemon) }
                if !captureDexNumbers.isEmpty {
                    HStack(spacing: 10) {
                        ForEach(captureDexNumbers, id: \.self) { dex in
                            spriteCircle(dexNumber: dex)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                Text("Pokémon esenciales para el run")
                    .font(KATypography.bodySmall)
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.top, KASpacing.xs)
            }
            .padding()
            .softCard(cornerRadius: KARadius.lg)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Shared Card

    private func teamPreviewCard(
        icon: String,
        title: String,
        count: Int,
        sprites: [(dexNumber: Int, emoji: String)],
        hint: String
    ) -> some View {
        VStack(spacing: KASpacing.sm + KASpacing.xs) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(theme.accent)
                Text(title)
                    .font(KATypography.titleSm)
                    .foregroundColor(theme.accent)
                Spacer()
                Text("\(count)/6")
                    .font(KATypography.bodySmall)
                    .foregroundColor(.onSurfaceVariant)
            }

            let rows = stride(from: 0, to: sprites.count, by: 3).map {
                Array(sprites[$0..<min($0 + 3, sprites.count)])
            }
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 10) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, sprite in
                        if sprite.dexNumber > 0 {
                            spriteCircle(dexNumber: sprite.dexNumber)
                                .frame(maxWidth: .infinity)
                        } else {
                            emptyCircle
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }

            Text(hint)
                .font(KATypography.bodySmall)
                .foregroundColor(.onSurfaceVariant)
                .padding(.top, KASpacing.xs)
        }
        .padding()
        .softCard(cornerRadius: KARadius.lg)
    }

    // MARK: - Sprite Helpers

    private func spriteCircle(dexNumber: Int) -> some View {
        ZStack {
            Circle()
                .fill(theme.accent.opacity(0.08))
                .frame(width: 52, height: 52)

            let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(dexNumber).png")
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.interpolation(.none).resizable().scaledToFit()
                        .frame(width: 40, height: 40)
                case .failure:
                    Image(systemName: "questionmark")
                        .foregroundColor(.onSurfaceVariant)
                default:
                    ProgressView().controlSize(.small)
                }
            }
        }
    }

    private var emptyCircle: some View {
        Circle()
            .fill(Color.surfaceContainerHighest)
            .frame(width: 52, height: 52)
    }

    // MARK: - Capture Dex Lookup

    private static let captureNameToDex: [String: Int] = [
        "Nidoran♂": 32, "Growlithe": 58, "Eevee": 133,
        "Exeggcute": 102, "Snorlax": 143,
    ]

    private func captureDexNumber(_ name: String) -> Int? {
        if let dex = Self.captureNameToDex[name] { return dex }
        let all = PokemonLoader.entries(forGameId: gameConfig.gameId)
        return all.first(where: { $0.name.lowercased() == name.lowercased() })?.id
    }
}
