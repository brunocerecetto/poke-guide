//
//  TeamView.swift
//  poke guide
//

import SwiftUI

struct TeamView: View {
    @EnvironmentObject var bridge: GameDataBridge
    @State private var expandedId: Int?

    var body: some View {
        PageLayout("Equipo Final") {
            VStack(spacing: KASpacing.sm + KASpacing.xs) {
                GuideDisclaimerBanner()

                HStack(spacing: 0) {
                    ForEach(bridge.team) { member in
                        Text(member.emoji)
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .opacity(expandedId == member.id ? 1.0 : 0.5)
                            .scaleEffect(expandedId == member.id ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: expandedId)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    expandedId = expandedId == member.id ? nil : member.id
                                }
                            }
                    }
                }
                .padding(.vertical, KASpacing.sm + KASpacing.xs)

                ForEach(bridge.team) { member in
                    pokemonCard(member)
                        .padding(.horizontal)
                }
            }
        }
    }

    private func pokemonCard(_ member: TeamMemberDTO) -> some View {
        let isExpanded = expandedId == member.id

        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                expandedId = isExpanded ? nil : member.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: KASpacing.sm + KASpacing.xs) {
                    Text(member.emoji)
                        .font(.system(size: 36))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.name)
                            .font(KATypography.headlineMd)
                            .foregroundColor(.onSurface)

                        HStack(spacing: KASpacing.xs) {
                            ForEach(member.moves.prefix(2), id: \.self) { move in
                                Text(move.components(separatedBy: " / ").first ?? move)
                                    .font(KATypography.labelXs)
                                    .foregroundColor(.onSurface.opacity(0.8))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(moveColor(move).opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            if !isExpanded {
                                Text("+\(member.moves.count - 2)")
                                    .font(KATypography.labelXs)
                                    .foregroundColor(.onSurfaceVariant)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.onSurfaceVariant)
                }
                .padding(KASpacing.md)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Spacer().frame(height: KASpacing.sm)

                        Text("MOVESET")
                            .font(KATypography.labelXs)
                            .foregroundColor(theme.accent)
                            .tracking(1)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                            ForEach(Array(member.moves.enumerated()), id: \.offset) { i, move in
                                HStack(spacing: 6) {
                                    Text("\(i + 1)")
                                        .font(KATypography.labelXs)
                                        .foregroundColor(moveColor(move))
                                    Text(move)
                                        .font(KATypography.bodySmall)
                                        .foregroundColor(.onSurface)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(KASpacing.sm)
                                .background(moveColor(move).opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: KASpacing.sm))
                            }
                        }

                        Text("NOTAS")
                            .font(KATypography.labelXs)
                            .foregroundColor(theme.accent)
                            .tracking(1)
                            .padding(.top, KASpacing.xs)

                        Text(member.notes)
                            .font(KATypography.bodySmall)
                            .foregroundColor(.onSurfaceVariant)
                    }
                    .padding(.horizontal, KASpacing.md)
                    .padding(.bottom, KASpacing.md)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: KARadius.lg)
                    .fill(Color.surfaceContainerLow)
            )
            .ghostBorder(cornerRadius: KARadius.lg, opacity: isExpanded ? 0.15 : 0.10)
            .clipShape(RoundedRectangle(cornerRadius: KARadius.lg))
        }
        .buttonStyle(.plain)
    }

    @Environment(\.themeColors) private var theme

    private static let moveColors: [String: Color] = [
        "Surf": .kaSecondaryContainer, "Ice Beam": .kaSecondaryContainer,
        "Thunderbolt": .kaYellow, "Shock Wave": .kaYellow, "Double Kick": .pink,
        "Flamethrower": .primaryContainer, "Bite": .primaryContainer, "Flame Wheel": .primaryContainer,
        "Earthquake": .brown, "Dig": .brown, "Brick Break": .brown,
        "Strength": .brown, "Return": .brown,
        "Psychic": .purple, "Giga Drain": .purple, "Sleep Powder": .purple, "Stun Spore": .purple,
        "Body Slam": .onSurfaceVariant, "Yawn": .onSurfaceVariant,
        "Rest": .onSurfaceVariant, "Shadow Ball": .onSurfaceVariant,
        "Aerial Ace": .pink,
        "Protect": .success,
    ]

    private func moveColor(_ move: String) -> Color {
        let primary = move.components(separatedBy: " / ").first ?? move
        return Self.moveColors[primary] ?? .onSurface
    }
}

#Preview {
    NavigationStack {
        TeamView()
            .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
    }
}
