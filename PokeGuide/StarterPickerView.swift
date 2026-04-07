//
//  StarterPickerView.swift
//  PokeGuide
//
//  Selección de starter para el juego elegido.
//

import SwiftUI

// MARK: - Starter Data

struct StarterInfo: Identifiable, Equatable {
    let id: Int
    let name: String
    let typeName: String
    let typeColor: Color
    let typeIcon: String

    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }
}

extension StarterInfo {
    static func starters(for dexNumbers: [Int]) -> [StarterInfo] {
        dexNumbers.compactMap { starterLookup[$0] }
    }

    private static let starterLookup: [Int: StarterInfo] = [
        1:   StarterInfo(id: 1,   name: "Bulbasaur",  typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        4:   StarterInfo(id: 4,   name: "Charmander", typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        7:   StarterInfo(id: 7,   name: "Squirtle",   typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        25:  StarterInfo(id: 25,  name: "Pikachu",    typeName: "Eléctrico", typeColor: PokemonType.electric.color, typeIcon: PokemonType.electric.icon),
        152: StarterInfo(id: 152, name: "Chikorita",  typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        155: StarterInfo(id: 155, name: "Cyndaquil",  typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        158: StarterInfo(id: 158, name: "Totodile",   typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        252: StarterInfo(id: 252, name: "Treecko",    typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        255: StarterInfo(id: 255, name: "Torchic",    typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        258: StarterInfo(id: 258, name: "Mudkip",     typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        387: StarterInfo(id: 387, name: "Turtwig",    typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        390: StarterInfo(id: 390, name: "Chimchar",   typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        393: StarterInfo(id: 393, name: "Piplup",     typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        495: StarterInfo(id: 495, name: "Snivy",      typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        498: StarterInfo(id: 498, name: "Tepig",      typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        501: StarterInfo(id: 501, name: "Oshawott",   typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        650: StarterInfo(id: 650, name: "Chespin",    typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        653: StarterInfo(id: 653, name: "Fennekin",   typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        656: StarterInfo(id: 656, name: "Froakie",    typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        722: StarterInfo(id: 722, name: "Rowlet",     typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        725: StarterInfo(id: 725, name: "Litten",     typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        728: StarterInfo(id: 728, name: "Popplio",    typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        810: StarterInfo(id: 810, name: "Grookey",    typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        813: StarterInfo(id: 813, name: "Scorbunny",  typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        816: StarterInfo(id: 816, name: "Sobble",     typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        906: StarterInfo(id: 906, name: "Sprigatito", typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        909: StarterInfo(id: 909, name: "Fuecoco",    typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        912: StarterInfo(id: 912, name: "Quaxly",     typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
    ]
}

// MARK: - Starter Picker View

struct StarterPickerView: View {
    let game: GameCatalogEntry
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameConfig: GameConfig
    @EnvironmentObject var progress: ProgressManager

    @State private var selectedStarter: StarterInfo?
    @State private var appeared = false
    @State private var showConfirmation = false

    private var starters: [StarterInfo] {
        StarterInfo.starters(for: game.starters)
    }

    var body: some View {
        ZStack {
            PixelBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: KASpacing.xl) {
                    header
                        .padding(.top, 20)

                    starterGrid

                    if selectedStarter != nil {
                        startButton
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .bold))
                        Text("Juegos")
                            .font(KATypography.titleSm)
                    }
                    .foregroundColor(game.accentColor)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .alert("Empezar aventura", isPresented: $showConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Empezar") {
                guard let starter = selectedStarter else { return }
                gameConfig.configure(
                    gameId: game.id,
                    starterDex: starter.id,
                    gameName: game.name,
                    accentColorHex: game.accentHex,
                    secondaryColorHex: game.secondaryHex,
                    iconName: game.icon
                )
                progress.switchConfig(prefix: gameConfig.progressPrefix)
            }
        } message: {
            if let starter = selectedStarter {
                Text("Vas a empezar \(game.name) con \(starter.name). ¡Buena suerte, Entrenador!")
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(game.accentColor.opacity(0.10))
                    .frame(width: 64, height: 64)

                Image(systemName: game.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(game.accentColor)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.6)

            Text(game.name)
                .font(KATypography.headlineLg)
                .foregroundColor(.onSurface)

            HStack(spacing: KASpacing.sm) {
                badgePill(text: game.region, color: game.accentColor)
                badgePill(text: game.platform, color: game.secondaryColor)
                if game.gymCount > 0 {
                    badgePill(text: "\(game.gymCount) gimnasios", color: .onSurfaceVariant)
                }
            }

            Text("Elegí tu starter")
                .font(KATypography.titleMd)
                .foregroundColor(.onSurfaceVariant)
                .padding(.top, KASpacing.xs)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -15)
    }

    private func badgePill(text: String, color: Color) -> some View {
        Text(text)
            .font(KATypography.labelSm)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, KASpacing.xs)
            .background(
                Capsule().fill(color.opacity(0.10))
            )
    }

    // MARK: - Starter Grid

    private var starterGrid: some View {
        let columns: [GridItem] = starters.count == 1
            ? [GridItem(.flexible())]
            : Array(repeating: GridItem(.flexible(), spacing: KASpacing.sm + KASpacing.xs), count: min(starters.count, 3))

        return LazyVGrid(columns: columns, spacing: KASpacing.md) {
            ForEach(Array(starters.enumerated()), id: \.element.id) { index, starter in
                starterCard(starter: starter, index: index)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedStarter = starter
                        }
                    }
            }
        }
        .padding(.horizontal)
    }

    private func starterCard(starter: StarterInfo, index: Int) -> some View {
        let isSelected = selectedStarter == starter

        return VStack(spacing: 10) {
            AsyncImage(url: starter.spriteURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                case .failure:
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.onSurfaceVariant.opacity(0.4))
                        .frame(width: 80, height: 80)
                default:
                    ProgressView()
                        .frame(width: 80, height: 80)
                }
            }

            Text(starter.name)
                .font(KATypography.titleMd)
                .foregroundColor(.onSurface)

            HStack(spacing: KASpacing.xs) {
                Image(systemName: starter.typeIcon)
                    .font(.system(size: 10))
                Text(starter.typeName)
                    .font(KATypography.bodySmall)
            }
            .foregroundColor(starter.typeColor)
            .padding(.horizontal, 10)
            .padding(.vertical, KASpacing.xs)
            .background(Capsule().fill(starter.typeColor.opacity(0.10)))

            Text("#\(String(format: "%03d", starter.id))")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.6))
        }
        .padding(.vertical, KASpacing.md)
        .padding(.horizontal, KASpacing.sm)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: KARadius.lg)
                .fill(isSelected ? Color.surfaceBright : Color.surfaceContainerLow)
        )
        .ghostBorder(cornerRadius: KARadius.lg, opacity: isSelected ? 0.20 : 0.10)
        .clipShape(RoundedRectangle(cornerRadius: KARadius.lg))
        .scaleEffect(isSelected ? 1.04 : 1)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(0.15 + Double(index) * 0.08),
            value: appeared
        )
    }

    // MARK: - Start Button (Energy Gradient CTA)

    private var startButton: some View {
        Button {
            showConfirmation = true
        } label: {
            HStack(spacing: KASpacing.sm) {
                Image(systemName: "play.fill")
                    .font(.system(size: 13, weight: .bold))
                Text("Empezar aventura")
                    .font(KATypography.titleMd)
            }
            .foregroundColor(.onPrimary)
            .padding(.horizontal, KASpacing.xl)
            .padding(.vertical, 15)
            .background(
                Capsule()
                    .fill(LinearGradient.energyGradient)
            )
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedStarter?.id)
    }
}

#Preview {
    NavigationStack {
        StarterPickerView(
            game: GameCatalogEntry.allGames.first { $0.id == "firered" } ?? GameCatalogEntry.allGames[0]
        )
    }
    .environmentObject(GameConfig())
    .environmentObject(ProgressManager())
}
