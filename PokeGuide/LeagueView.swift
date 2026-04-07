//
//  LeagueView.swift
//  poke guide
//

import SwiftUI

struct LeagueView: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme
    @State private var celebrateLeague = false

    var body: some View {
        ZStack {
            Color.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: KASpacing.md) {
                    GuideDisclaimerBanner()

                    sectionHeader(title: "CHECKLIST PRE-LIGA", icon: "checklist")

                    VStack(spacing: 6) {
                        ForEach(bridge.preLeagueChecklist) { step in
                            checkRow(
                                text: step.text,
                                isCompleted: progress.isPreLeagueCompleted(step.id),
                                action: { progress.togglePreLeague(step.id) }
                            )
                        }
                    }
                    .padding(.horizontal)

                    Spacer().frame(height: KASpacing.sm)

                    sectionHeader(title: "ELITE FOUR — PLAN EXACTO", icon: "trophy.fill")

                    VStack(spacing: 10) {
                        ForEach(bridge.eliteFour) { member in
                            eliteMemberCard(member)
                        }
                    }
                    .padding(.horizontal)

                    Spacer().frame(height: KASpacing.sm)

                    sectionHeader(title: "POSTGAME OPCIONAL", icon: "star.circle")

                    VStack(spacing: 6) {
                        ForEach(bridge.postgameChecklist) { step in
                            checkRow(
                                text: step.text,
                                isCompleted: progress.isPostgameCompleted(step.id),
                                action: { progress.togglePostgame(step.id) }
                            )
                        }
                    }
                    .padding(.horizontal)

                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.kaSecondaryContainer)
                        Text("Rock Smash y Waterfall son HMs de postgame en Sevii Islands.")
                            .font(KATypography.labelSm)
                            .foregroundColor(.kaSecondaryContainer)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.surfaceContainerHighest)
                    .clipShape(RoundedRectangle(cornerRadius: KARadius.sm))
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding(.top, KASpacing.sm)
            }

            if celebrateLeague {
                ConfettiView(trigger: celebrateLeague)
            }
        }
        .navigationTitle("Liga Pokémon")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.automatic, for: .navigationBar)
        .task(id: celebrateLeague) {
            guard celebrateLeague else { return }
            try? await Task.sleep(for: .seconds(2))
            celebrateLeague = false
        }
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: KASpacing.sm) {
            Image(systemName: icon)
                .foregroundColor(theme.accent)
            Text(title)
                .font(KATypography.labelSm)
                .foregroundColor(theme.accent)
                .tracking(1)
        }
        .padding(.horizontal)
    }

    private func eliteMemberCard(_ member: EliteFourMemberDTO) -> some View {
        let completed = progress.isLeagueCompleted(member.name)

        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                progress.toggleLeague(member.name)
            }
            if progress.completedLeague.count == bridge.eliteFour.count {
                celebrateLeague = true
            }
        } label: {
            HStack(spacing: KASpacing.md) {
                ZStack {
                    Circle()
                        .fill(completed ? Color.success.gradient : theme.accent.gradient)
                        .frame(width: 44, height: 44)

                    if completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.onPrimary)
                    } else {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.onPrimary)
                    }
                }

                VStack(alignment: .leading, spacing: KASpacing.xs) {
                    HStack {
                        Text(member.name)
                            .font(KATypography.titleMd)
                            .foregroundColor(completed ? .onSurfaceVariant : .onSurface)
                            .strikethrough(completed)

                        Spacer()

                        TypeBadge(text: "Nv. \(member.levels)", color: completed ? .success : theme.accent)
                    }

                    Text(member.strategy)
                        .font(KATypography.bodySmall)
                        .foregroundColor(.onSurfaceVariant)
                        .lineLimit(3)
                }
            }
            .padding(KASpacing.sm + KASpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: KARadius.lg)
                    .fill(completed ? Color.success.opacity(0.06) : Color.surfaceContainerLow)
            )
            .ghostBorder(cornerRadius: KARadius.lg, opacity: completed ? 0.15 : 0.10)
            .clipShape(RoundedRectangle(cornerRadius: KARadius.lg))
            .opacity(completed ? 0.7 : 1)
        }
        .buttonStyle(.plain)
    }

    private func checkRow(text: String, isCompleted: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        } label: {
            HStack(spacing: KASpacing.sm + KASpacing.xs) {
                AnimatedCheck(isCompleted: isCompleted, size: 22)

                Text(text)
                    .font(KATypography.bodySmall)
                    .foregroundColor(isCompleted ? .onSurfaceVariant : .onSurface)
                    .strikethrough(isCompleted, color: .onSurfaceVariant)

                Spacer()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: KARadius.sm)
                    .fill(isCompleted ? Color.success.opacity(0.04) : Color.surfaceContainerLow)
            )
            .opacity(isCompleted ? 0.7 : 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        LeagueView()
            .environmentObject(ProgressManager())
            .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
    }
}
