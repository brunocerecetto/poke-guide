//
//  ContentView.swift
//  pokemon guide
//
//  Created by Bruno Cerecetto on 6/4/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var gameConfig: GameConfig
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme
    @State private var showResetAlert = false
    @State private var showChangeGameAlert = false
    @State private var appeared = false

    // MARK: - Data-Driven Helpers

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

    private var starterName: String {
        let starterNames: [Int: String] = [
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
        if gameConfig.starterDex > 0, let name = starterNames[gameConfig.starterDex] {
            return name
        }
        return gameConfig.legacyStarter?.displayName ?? "Starter"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    heroHeader
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -20)

                    primaryGrid
                        .padding(.horizontal)

                    secondaryList
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
                            .foregroundColor(.fireTextSecondary)
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
        VStack(spacing: 16) {
            Spacer().frame(height: 6)

            VStack(spacing: 5) {
                Text("GUÍA DEFINITIVA")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.secondary)
                    .tracking(4)

                Text("\(starterName) Run")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(.fireTextPrimary)
            }

            PokeballProgress(progress: bridgeProgressFraction)

            HStack(spacing: 5) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.fireGreen)
                Text("\(progress.totalCompleted)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.fireTextPrimary)
                Text("/")
                    .foregroundColor(.fireTextSecondary)
                Text("\(progress.totalCheckable(from: bridge))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
                Text("pasos")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
            }

            Spacer().frame(height: 4)
        }
        .frame(maxWidth: .infinity)
        .softCard(cornerRadius: 24, tint: theme.accent, shadowRadius: 14)
        .padding(.horizontal)
    }

    // MARK: - Primary Grid

    private var primaryGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(primaryItems.enumerated()), id: \.element.title) { index, item in
                NavigationLink {
                    destinationView(for: item.destination)
                } label: {
                    bigCard(item: item)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.08 + Double(index) * 0.05), value: appeared)
            }
        }
    }

    private func bigCard(item: MenuItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.color.opacity(0.10))
                    .frame(width: 44, height: 44)

                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(item.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.fireTextPrimary)
                    .lineLimit(1)
                Text(item.subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .softCard(cornerRadius: 18, tint: item.color)
    }

    // MARK: - Secondary List

    private var secondaryList: some View {
        VStack(spacing: 8) {
            ForEach(Array(secondaryItems.enumerated()), id: \.element.title) { index, item in
                NavigationLink {
                    destinationView(for: item.destination)
                } label: {
                    slimCard(item: item)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3 + Double(index) * 0.04), value: appeared)
            }
        }
    }

    private func slimCard(item: MenuItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.color.opacity(0.10))
                    .frame(width: 38, height: 38)

                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(item.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.fireTextPrimary)
                Text(item.subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.black.opacity(0.15))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .softCard(cornerRadius: 16, tint: item.color, shadowRadius: 6)
    }

    // MARK: - Footer

    private var footerBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: displayIconName)
                .font(.system(size: 9))
            Text("Gen I — Kanto")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
        }
        .foregroundColor(.fireTextSecondary.opacity(0.5))
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.6), value: appeared)
    }

    // MARK: - Data

    private enum Destination: Hashable {
        case gyms, team, route, pokedex, captures, hmtm, tips, league
        case typeChart, rival, evolutions, teamBuilder
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
        case .team: TeamView()
        case .route: RouteView()
        case .pokedex: PokedexView()
        case .captures: CapturesView()
        case .hmtm: HMTMView()
        case .tips: TipsView()
        case .league: LeagueView()
        case .typeChart: TypeChartView()
        case .rival: RivalView()
        case .evolutions: EvolutionView()
        case .teamBuilder: TeamBuilderView()
        }
    }

    private var primaryItems: [MenuItem] {
        [
            MenuItem(icon: "shield.checkered", title: "Gimnasios", subtitle: "\(progress.completedGyms.count)/8 badges", color: theme.accent, destination: .gyms),
            MenuItem(icon: "person.3.fill", title: "Equipo Final", subtitle: "6 pokémon + movesets", color: .fireBlue, destination: .team),
            MenuItem(icon: "map.fill", title: "Ruta Completa", subtitle: "Paso a paso", color: .fireGreen, destination: .route),
            MenuItem(icon: "book.closed.fill", title: "Pokédex", subtitle: "\(progress.pokemonStatuses.filter { $0.value.rawValue >= 2 }.count)/151 capturados", color: Color(red: 0.85, green: 0.25, blue: 0.25), destination: .pokedex),
        ]
    }

    private var secondaryItems: [MenuItem] {
        [
            MenuItem(icon: "scope", title: "Capturas Clave", subtitle: "5 pokémon esenciales", color: .purple, destination: .captures),
            MenuItem(icon: "arrow.triangle.swap", title: "HMs & TMs", subtitle: "Reparto y compras", color: .teal, destination: .hmtm),
            MenuItem(icon: "lightbulb.fill", title: "Tips & Tricks", subtitle: "Reglas de evolución y más", color: .fireYellow, destination: .tips),
            MenuItem(icon: "trophy.fill", title: "Liga Pokémon", subtitle: "Plan + checklist final", color: theme.secondary, destination: .league),
            MenuItem(icon: "square.grid.3x3.fill", title: "Tabla de Tipos", subtitle: "Efectividad de ataques", color: Color(red: 0.76, green: 0.18, blue: 0.16), destination: .typeChart),
            MenuItem(icon: "person.fill.questionmark", title: "Rival", subtitle: "Equipo del rival por pelea", color: .fireBlue, destination: .rival),
            MenuItem(icon: "arrow.triangle.branch", title: "Evoluciones", subtitle: "Cadenas y métodos", color: .fireGreen, destination: .evolutions),
            MenuItem(icon: "hammer.fill", title: "Team Builder", subtitle: "Armá tu equipo ideal", color: .fireOrange, destination: .teamBuilder),
        ]
    }
}

#Preview {
    ContentView()
        .environmentObject(ProgressManager())
        .environmentObject(GameConfig())
        .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
}
