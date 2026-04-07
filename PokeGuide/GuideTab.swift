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

                    Text("ADVENTURE DASHBOARD")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.onSurfaceVariant)
                        .tracking(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

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

    private var regionName: String {
        let game = GameCatalogEntry.allGames.first { $0.id == gameConfig.gameId }
        return game?.region ?? "Kanto"
    }

    private var starterSpriteURL: URL? {
        let dex = gameConfig.starterDex
        guard dex > 0 else { return nil }
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(dex).png")
    }

    private var heroHeader: some View {
        let totalSteps = progress.totalCheckable(from: bridge)
        let completed = progress.totalCompleted
        let percent = Int(bridgeProgressFraction * 100)

        return VStack(spacing: 8) {
            // Top row: badge + progress ring
            HStack(alignment: .top) {
                Text("ACTIVE GUIDE")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(Color.white.opacity(0.22))
                    )

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 5)
                        .frame(width: 56, height: 56)

                    Circle()
                        .trim(from: 0, to: bridgeProgressFraction)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))

                    Text("\(percent)%")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
            }

            // Region Journey title
            VStack(alignment: .leading, spacing: 2) {
                Text(regionName)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("Journey")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Bottom row: progress count + starter image
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("PROGRESS")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(2)

                    Text("\(completed)/\(totalSteps) PASOS")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                AsyncImage(url: starterSpriteURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        Image(systemName: displayIconName)
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .frame(width: 130, height: 130)
                .frame(height: 80)
                .offset(y: -25)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: KARadius.xl)
                    .fill(theme.accent)

                RoundedRectangle(cornerRadius: KARadius.xl)
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.2), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: KARadius.xl))
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
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.onSurfaceVariant)
                    .tracking(1.5)
                    .lineLimit(2)
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
            MenuItem(icon: "shield.checkered", title: "Gimnasios", subtitle: "\(progress.completedGyms.count) DE \(bridge.gyms.count) MEDALLAS", color: theme.accent, destination: .gyms),
            MenuItem(icon: "map.fill", title: "Ruta Completa", subtitle: "VER ITINERARIO", color: .success, destination: .route),
            MenuItem(icon: "trophy.fill", title: "Liga Pokémon", subtitle: "NIVEL REQUERIDO: 50", color: theme.secondary, destination: .league),
            MenuItem(icon: "person.fill.questionmark", title: "Rival", subtitle: "ÚLTIMO ENCUENTRO: —", color: .kaSecondaryContainer, destination: .rival),
        ]
    }
}
