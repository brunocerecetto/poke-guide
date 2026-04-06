//
//  StarterPickerView.swift
//  PokemonGuide
//
//  Selección de starter para el juego elegido.
//

import SwiftUI

// MARK: - Mock Starter Data

struct MockStarter: Identifiable, Equatable {
    let id: Int // dex number
    let name: String
    let typeName: String
    let typeColor: Color
    let typeIcon: String

    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }
}

extension MockStarter {
    /// Maps dex numbers to starter info. Covers all generations.
    static func starters(for dexNumbers: [Int]) -> [MockStarter] {
        dexNumbers.compactMap { starterLookup[$0] }
    }

    private static let starterLookup: [Int: MockStarter] = [
        // Gen I
        1:   MockStarter(id: 1,   name: "Bulbasaur",  typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        4:   MockStarter(id: 4,   name: "Charmander", typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        7:   MockStarter(id: 7,   name: "Squirtle",   typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        25:  MockStarter(id: 25,  name: "Pikachu",    typeName: "Eléctrico", typeColor: PokemonType.electric.color, typeIcon: PokemonType.electric.icon),
        // Gen II
        152: MockStarter(id: 152, name: "Chikorita",  typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        155: MockStarter(id: 155, name: "Cyndaquil",  typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        158: MockStarter(id: 158, name: "Totodile",   typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        // Gen III
        252: MockStarter(id: 252, name: "Treecko",    typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        255: MockStarter(id: 255, name: "Torchic",    typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        258: MockStarter(id: 258, name: "Mudkip",     typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        // Gen IV
        387: MockStarter(id: 387, name: "Turtwig",    typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        390: MockStarter(id: 390, name: "Chimchar",   typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        393: MockStarter(id: 393, name: "Piplup",     typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        // Gen V
        495: MockStarter(id: 495, name: "Snivy",      typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        498: MockStarter(id: 498, name: "Tepig",      typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        501: MockStarter(id: 501, name: "Oshawott",   typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        // Gen VI
        650: MockStarter(id: 650, name: "Chespin",    typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        653: MockStarter(id: 653, name: "Fennekin",   typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        656: MockStarter(id: 656, name: "Froakie",    typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        // Gen VII
        722: MockStarter(id: 722, name: "Rowlet",     typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        725: MockStarter(id: 725, name: "Litten",     typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        728: MockStarter(id: 728, name: "Popplio",    typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        // Gen VIII
        810: MockStarter(id: 810, name: "Grookey",    typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        813: MockStarter(id: 813, name: "Scorbunny",  typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        816: MockStarter(id: 816, name: "Sobble",     typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
        // Gen IX
        906: MockStarter(id: 906, name: "Sprigatito", typeName: "Planta",    typeColor: PokemonType.grass.color,    typeIcon: PokemonType.grass.icon),
        909: MockStarter(id: 909, name: "Fuecoco",    typeName: "Fuego",     typeColor: PokemonType.fire.color,     typeIcon: PokemonType.fire.icon),
        912: MockStarter(id: 912, name: "Quaxly",     typeName: "Agua",      typeColor: PokemonType.water.color,    typeIcon: PokemonType.water.icon),
    ]
}

// MARK: - Starter Picker View

struct StarterPickerView: View {
    let game: MockGame
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameConfig: GameConfig
    @EnvironmentObject var progress: ProgressManager

    @State private var selectedStarter: MockStarter?
    @State private var appeared = false
    @State private var showConfirmation = false

    private var starters: [MockStarter] {
        MockStarter.starters(for: game.starters)
    }

    var body: some View {
        ZStack {
            PixelBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
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
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
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
            // Game icon
            ZStack {
                Circle()
                    .fill(game.accentColor.opacity(0.12))
                    .frame(width: 64, height: 64)

                Image(systemName: game.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(game.accentColor)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.6)

            Text(game.name)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(.fireTextPrimary)

            HStack(spacing: 8) {
                badgePill(text: game.region, color: game.accentColor)
                badgePill(text: game.platform, color: game.secondaryColor)
                if game.gymCount > 0 {
                    badgePill(text: "\(game.gymCount) gimnasios", color: .fireTextSecondary)
                }
            }

            Text("Elegí tu starter")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.fireTextSecondary)
                .padding(.top, 4)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -15)
    }

    private func badgePill(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(color.opacity(0.12))
            )
    }

    // MARK: - Starter Grid

    private var starterGrid: some View {
        let columns: [GridItem] = starters.count == 1
            ? [GridItem(.flexible())]
            : Array(repeating: GridItem(.flexible(), spacing: 12), count: min(starters.count, 3))

        return LazyVGrid(columns: columns, spacing: 14) {
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

    private func starterCard(starter: MockStarter, index: Int) -> some View {
        let isSelected = selectedStarter == starter

        return VStack(spacing: 10) {
            // Sprite
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
                        .foregroundColor(.fireTextSecondary.opacity(0.4))
                        .frame(width: 80, height: 80)
                default:
                    ProgressView()
                        .frame(width: 80, height: 80)
                }
            }

            // Name
            Text(starter.name)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.fireTextPrimary)

            // Type badge
            HStack(spacing: 4) {
                Image(systemName: starter.typeIcon)
                    .font(.system(size: 10))
                Text(starter.typeName)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundColor(starter.typeColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(starter.typeColor.opacity(0.12)))

            // Dex number
            Text("#\(String(format: "%03d", starter.id))")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.fireTextSecondary.opacity(0.6))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.fireCard)
                .shadow(
                    color: isSelected ? game.accentColor.opacity(0.2) : .black.opacity(0.06),
                    radius: isSelected ? 14 : 6,
                    y: 3
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? game.accentColor.opacity(0.5) : Color.clear, lineWidth: 2.5)
        )
        .scaleEffect(isSelected ? 1.04 : 1)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(0.15 + Double(index) * 0.08),
            value: appeared
        )
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            showConfirmation = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                    .font(.system(size: 13, weight: .bold))
                Text("Empezar aventura")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 15)
            .background(
                Capsule()
                    .fill(game.accentColor)
                    .shadow(color: game.accentColor.opacity(0.3), radius: 10, y: 4)
            )
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedStarter?.id)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StarterPickerView(
            game: MockGame.mockGames.first { $0.id == "firered" }!
        )
    }
    .environmentObject(GameConfig())
    .environmentObject(ProgressManager())
}
