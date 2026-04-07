//
//  GuideTab.swift
//  PokeGuide
//
//  Dashboard + guide navigation: Gimnasios, Ruta, Liga, Rival.
//

import SwiftUI

struct GuideTab: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var gameConfig: GameConfig
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme
    @State private var showResetAlert = false
    @State private var showChangeGameAlert = false
    @State private var appeared = false

    private var displayGameName: String {
        if !gameConfig.gameName.isEmpty { return gameConfig.gameName }
        return gameConfig.version.displayName
    }

    private var displayIconName: String {
        if !gameConfig.iconName.isEmpty { return gameConfig.iconName }
        return gameConfig.version.icon
    }

    private var bridgeProgressFraction: Double {
        let total = progress.totalCheckable(from: bridge)
        guard total > 0 else { return 0 }
        return Double(progress.totalCompleted) / Double(total)
    }

    private static let starterNames: [Int: String] = [
        1: "Bulbasaur", 4: "Charmander", 7: "Squirtle", 25: "Pikachu",
        152: "Chikorita", 155: "Cyndaquil", 158: "Totodile",
        252: "Treecko", 255: "Torchic", 258: "Mudkip",
        387: "Turtwig", 390: "Chimchar", 393: "Piplup",
        495: "Snivy", 498: "Tepig", 501: "Oshawott",
        650: "Chespin", 653: "Fennekin", 656: "Froakie",
        722: "Rowlet", 725: "Litten", 728: "Popplio",
        810: "Grookey", 813: "Scorbunny", 816: "Sobble",
        906: "Sprigatito", 909: "Fuecoco", 912: "Quaxly",
        133: "Eevee",
    ]

    private var starterName: String {
        if gameConfig.starterDex > 0, let name = Self.starterNames[gameConfig.starterDex] {
            return name
        }
        return gameConfig.legacyStarter?.displayName ?? "Starter"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: KASpacing.lg) {
                    heroHeader
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -20)

                    guideGrid
                        .padding(.horizontal)

                    footerBadge
                        .padding(.bottom, 30)
                }
            }
            .background(PixelBackground())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 5) {
                        Image(systemName: displayIconName)
                            .font(.system(size: 11))
                            .foregroundColor(theme.accent)
                        Text(displayGameName)
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(theme.accent)
                            .tracking(2)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showChangeGameAlert = true
                        } label: {
                            Label("Cambiar juego/starter", systemImage: "arrow.triangle.2.circlepath")
                        }
                        Button(role: .destructive) {
                            showResetAlert = true
                        } label: {
                            Label("Resetear progreso", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.onSurfaceVariant)
                    }
                }
            }
            .alert("Resetear progreso", isPresented: $showResetAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Resetear", role: .destructive) { progress.resetAll() }
            } message: {
                Text("Se van a borrar todos los checks. ¿Estás seguro?")
            }
            .alert("Cambiar juego/starter", isPresented: $showChangeGameAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Cambiar", role: .destructive) {
                    gameConfig.unconfigure()
                }
            } message: {
                Text("Vas a volver a la pantalla de selección. Tu progreso actual se guarda y podés volver a esta configuración.")
            }
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) { appeared = true }
            }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: KASpacing.md) {
            Spacer().frame(height: 6)

            VStack(spacing: 5) {
                Text("GUÍA DEFINITIVA")
                    .font(KATypography.labelXs)
                    .foregroundColor(theme.secondary)
                    .tracking(4)

                Text("\(starterName) Run")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(.onSurface)
            }

            PokeballProgress(progress: bridgeProgressFraction)

            HStack(spacing: 5) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.success)
                Text("\(progress.totalCompleted)")
                    .font(KATypography.titleSm)
                    .foregroundColor(.onSurface)
                Text("/")
                    .foregroundColor(.onSurfaceVariant)
                Text("\(progress.totalCheckable(from: bridge))")
                    .font(KATypography.titleSm)
                    .foregroundColor(.onSurfaceVariant)
                Text("pasos")
                    .font(KATypography.bodySmall)
                    .foregroundColor(.onSurfaceVariant)
            }

            Spacer().frame(height: KASpacing.xs)
        }
        .frame(maxWidth: .infinity)
        .softCard(cornerRadius: KARadius.xl, tint: theme.accent)
        .padding(.horizontal)
    }

    // MARK: - Guide Grid

    private var guideGrid: some View {
        let columns = [GridItem(.flexible(), spacing: KASpacing.sm + KASpacing.xs), GridItem(.flexible(), spacing: KASpacing.sm + KASpacing.xs)]

        return LazyVGrid(columns: columns, spacing: KASpacing.sm + KASpacing.xs) {
            ForEach(Array(guideItems.enumerated()), id: \.element.title) { index, item in
                NavigationLink {
                    destinationView(for: item.destination)
                } label: {
                    guideCard(item: item)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.08 + Double(index) * 0.05), value: appeared)
            }
        }
    }

    private func guideCard(item: MenuItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: KARadius.sm)
                    .fill(item.color.opacity(0.10))
                    .frame(width: 44, height: 44)

                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(item.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(KATypography.titleSm)
                    .foregroundColor(.onSurface)
                    .lineLimit(1)
                Text(item.subtitle)
                    .font(KATypography.labelSm)
                    .foregroundColor(.onSurfaceVariant)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg, tint: item.color)
    }

    // MARK: - Footer

    private var footerBadge: some View {
        let game = GameCatalogEntry.allGames.first { $0.id == gameConfig.gameId }
        let regionLabel = game.map { "Gen \($0.generation) — \($0.region)" } ?? "Gen I — Kanto"

        return HStack(spacing: 5) {
            Image(systemName: displayIconName)
                .font(.system(size: 9))
            Text(regionLabel)
                .font(KATypography.labelXs)
        }
        .foregroundColor(.onSurfaceVariant.opacity(0.5))
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.6), value: appeared)
    }

    // MARK: - Data

    private enum Destination: Hashable {
        case gyms, route, league, rival
    }

    private struct MenuItem: Identifiable {
        var id: String { title }
        let icon: String
        let title: String
        let subtitle: String
        let color: Color
        let destination: Destination
    }

    @ViewBuilder
    private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .gyms: GymView()
        case .route: RouteView()
        case .league: LeagueView()
        case .rival: RivalView()
        }
    }

    private var guideItems: [MenuItem] {
        [
            MenuItem(icon: "shield.checkered", title: "Gimnasios", subtitle: "\(progress.completedGyms.count)/\(bridge.gyms.count) badges", color: theme.accent, destination: .gyms),
            MenuItem(icon: "map.fill", title: "Ruta Completa", subtitle: "Paso a paso", color: .success, destination: .route),
            MenuItem(icon: "trophy.fill", title: "Liga Pokémon", subtitle: "Plan + checklist final", color: theme.secondary, destination: .league),
            MenuItem(icon: "person.fill.questionmark", title: "Rival", subtitle: "Equipo del rival por pelea", color: .kaSecondaryContainer, destination: .rival),
        ]
    }
}
