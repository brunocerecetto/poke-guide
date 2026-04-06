//
//  GameSelectionView.swift
//  PokemonGuide
//
//  Pantalla de selección de versión del juego y starter.
//

import SwiftUI

struct GameSelectionView: View {
    @EnvironmentObject var gameConfig: GameConfig
    @EnvironmentObject var progress: ProgressManager

    @State private var selectedVersion: GameVersion?
    @State private var selectedStarter: Starter?
    @State private var step: SelectionStep = .version

    private enum SelectionStep {
        case version, starter
    }

    var body: some View {
        ZStack {
            PixelBackground()

            VStack(spacing: 0) {
                Spacer().frame(height: 50)

                // Title
                VStack(spacing: 6) {
                    Text("POKÉMON GUIDE")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(.fireTextSecondary)
                        .tracking(4)

                    Text(step == .version ? "Elegí tu versión" : "Elegí tu starter")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.fireTextPrimary)
                }
                .padding(.bottom, 30)

                if step == .version {
                    versionSelection
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    starterSelection
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }

                Spacer()

                // Navigation buttons
                HStack(spacing: 16) {
                    if step == .starter {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                step = .version
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Atrás")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.fireTextSecondary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                Capsule().fill(Color.black.opacity(0.05))
                            )
                        }
                    }

                    if step == .version, selectedVersion != nil {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                step = .starter
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text("Siguiente")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                Capsule().fill(selectedVersion?.accentColor ?? .fireRed)
                            )
                        }
                    }

                    if step == .starter, let version = selectedVersion, let starter = selectedStarter {
                        Button {
                            gameConfig.configure(version: version, starter: starter)
                            progress.switchConfig(prefix: gameConfig.progressPrefix)
                        } label: {
                            HStack(spacing: 6) {
                                Text("Empezar")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(
                                Capsule().fill(version.accentColor)
                            )
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }

    // MARK: - Version Selection

    private var versionSelection: some View {
        VStack(spacing: 14) {
            ForEach(GameVersion.allCases, id: \.self) { version in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedVersion = version
                    }
                } label: {
                    versionCard(version: version, isSelected: selectedVersion == version)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }

    private func versionCard(version: GameVersion, isSelected: Bool) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(version.accentColor.opacity(0.12))
                    .frame(width: 56, height: 56)

                Image(systemName: version.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(version.accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(version.shortName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.fireTextPrimary)

                Text(version == .fireRed ? "Exclusivos: Growlithe, Scyther, Electabuzz..." : "Exclusivos: Vulpix, Pinsir, Magmar...")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
                    .lineLimit(1)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(version.accentColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.fireCard)
                .shadow(color: isSelected ? version.accentColor.opacity(0.15) : .black.opacity(0.06), radius: isSelected ? 12 : 6, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? version.accentColor.opacity(0.4) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1)
    }

    // MARK: - Starter Selection

    private var starterSelection: some View {
        VStack(spacing: 14) {
            ForEach(Starter.allCases, id: \.self) { starter in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedStarter = starter
                    }
                } label: {
                    starterCard(starter: starter, isSelected: selectedStarter == starter)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }

    private func starterCard(starter: Starter, isSelected: Bool) -> some View {
        HStack(spacing: 16) {
            AsyncImage(url: starter.spriteURL) { phase in
                switch phase {
                case .success(let image):
                    image.interpolation(.none).resizable().scaledToFit()
                        .frame(width: 56, height: 56)
                case .failure:
                    Text(starter.emoji)
                        .font(.system(size: 30))
                        .frame(width: 56, height: 56)
                default:
                    ProgressView().frame(width: 56, height: 56)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(starter.displayName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.fireTextPrimary)

                HStack(spacing: 4) {
                    Image(systemName: starter.type.icon)
                        .font(.system(size: 10))
                    Text(starter.type.rawValue.capitalized)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundColor(starter.type.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(starter.type.color.opacity(0.12)))
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(selectedVersion?.accentColor ?? .fireRed)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.fireCard)
                .shadow(color: isSelected ? (selectedVersion?.accentColor ?? .fireRed).opacity(0.15) : .black.opacity(0.06), radius: isSelected ? 12 : 6, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? (selectedVersion?.accentColor ?? .fireRed).opacity(0.4) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1)
    }
}

#Preview {
    GameSelectionView()
        .environmentObject(GameConfig())
        .environmentObject(ProgressManager())
}
