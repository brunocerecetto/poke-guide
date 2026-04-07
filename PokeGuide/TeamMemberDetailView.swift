//
//  TeamMemberDetailView.swift
//  PokeGuide
//

import SwiftUI

struct TeamMemberDetailView: View {
    let member: TeamMemberDTO
    @Environment(\.themeColors) private var theme

    var body: some View {
        PageLayout(member.name) {
            VStack(spacing: KASpacing.lg) {
                // Hero sprite
                heroSection

                // Moveset
                movesetSection

                // Notes
                notesSection
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: KASpacing.sm) {
            AsyncImage(url: member.spriteURL) { phase in
                switch phase {
                case .success(let image):
                    image.interpolation(.none).resizable().scaledToFit()
                        .frame(width: 120, height: 120)
                case .failure:
                    Text(member.emoji)
                        .font(.system(size: 64))
                        .frame(width: 120, height: 120)
                case .empty:
                    ProgressView()
                        .frame(width: 120, height: 120)
                @unknown default:
                    EmptyView()
                }
            }

            Text("#\(member.dexNumber)")
                .font(KATypography.labelSm)
                .foregroundColor(.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, KASpacing.lg)
        .softCard(cornerRadius: KARadius.lg)
    }

    // MARK: - Moveset

    private var movesetSection: some View {
        VStack(alignment: .leading, spacing: KASpacing.sm + KASpacing.xs) {
            KASectionHeader(title: "Moveset", icon: "bolt.fill")

            ForEach(Array(member.moves.enumerated()), id: \.offset) { i, move in
                HStack(spacing: KASpacing.sm + KASpacing.xs) {
                    Text("\(i + 1)")
                        .font(KATypography.labelXs)
                        .foregroundColor(theme.accent)
                        .frame(width: 18)

                    Text(move)
                        .font(KATypography.titleSm)
                        .foregroundColor(.onSurface)

                    Spacer()

                    movePill(move)
                }
                .padding(KASpacing.sm + KASpacing.xs)
                .background(moveColor(move).opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: KARadius.sm))
            }
        }
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg)
    }

    private func movePill(_ move: String) -> some View {
        let primary = move.components(separatedBy: " / ").first ?? move
        let color = moveColor(move)
        return Text(primary)
            .font(KATypography.labelXs)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: KASpacing.sm + KASpacing.xs) {
            KASectionHeader(title: "Notas", icon: "text.book.closed.fill")

            Text(member.notes)
                .font(KATypography.bodySmall)
                .foregroundColor(.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg)
    }

    // MARK: - Move Colors

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
