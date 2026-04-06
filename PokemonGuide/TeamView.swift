//
//  TeamView.swift
//  pokemon guide
//

import SwiftUI

struct TeamView: View {
    @State private var expandedId: UUID?

    var body: some View {
        ZStack {
            Color.fireBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    GuideDisclaimerBanner()

                    // Team overview bar
                    HStack(spacing: 0) {
                        ForEach(GameData.team) { member in
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
                    .padding(.vertical, 12)

                    ForEach(GameData.team) { member in
                        pokemonCard(member)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Equipo Final")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.automatic, for: .navigationBar)
    }

    private func pokemonCard(_ member: TeamMember) -> some View {
        let isExpanded = expandedId == member.id

        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                expandedId = isExpanded ? nil : member.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Text(member.emoji)
                        .font(.system(size: 36))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.name)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.fireTextPrimary)

                        // Moves preview
                        HStack(spacing: 4) {
                            ForEach(member.moves.prefix(2), id: \.self) { move in
                                Text(move.components(separatedBy: " / ").first ?? move)
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundColor(.fireTextPrimary.opacity(0.8))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(moveColor(move).opacity(0.5))
                                    .clipShape(Capsule())
                            }
                            if !isExpanded {
                                Text("+\(member.moves.count - 2)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(.fireTextSecondary)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.fireTextSecondary)
                }
                .padding(14)

                // Expanded content
                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Divider()
                            .background(Color.fireTextSecondary.opacity(0.3))

                        // All moves
                        Text("MOVESET")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.fireOrange)
                            .tracking(1)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                            ForEach(Array(member.moves.enumerated()), id: \.offset) { i, move in
                                HStack(spacing: 6) {
                                    Text("\(i + 1)")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundColor(moveColor(move))
                                    Text(move)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.fireTextPrimary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(moveColor(move).opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }

                        // Notes
                        Text("NOTAS")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.fireOrange)
                            .tracking(1)
                            .padding(.top, 4)

                        Text(member.notes)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.fireTextSecondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isExpanded ? Color.fireCard.opacity(0.9) : Color.fireCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isExpanded ? Color.fireOrange.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private static let moveColors: [String: Color] = [
        "Surf": .fireBlue, "Ice Beam": .fireBlue,
        "Thunderbolt": .fireYellow, "Shock Wave": .fireYellow, "Double Kick": .pink,
        "Flamethrower": .fireOrange, "Bite": .fireOrange, "Flame Wheel": .fireOrange,
        "Earthquake": .brown, "Dig": .brown, "Brick Break": .brown,
        "Strength": .brown, "Return": .brown,
        "Psychic": .purple, "Giga Drain": .purple, "Sleep Powder": .purple, "Stun Spore": .purple,
        "Body Slam": .fireTextSecondary, "Yawn": .fireTextSecondary,
        "Rest": .fireTextSecondary, "Shadow Ball": .fireTextSecondary,
        "Aerial Ace": .pink,
        "Protect": .fireGreen,
    ]

    private func moveColor(_ move: String) -> Color {
        // Handle composite moves like "Protect / Strength" — match on first option
        let primary = move.components(separatedBy: " / ").first ?? move
        return Self.moveColors[primary] ?? .fireTextPrimary
    }
}

#Preview {
    NavigationStack {
        TeamView()
    }
}
