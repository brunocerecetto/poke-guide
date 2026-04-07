//
//  LeagueView.swift
//  pokemon guide
//

import SwiftUI

struct LeagueView: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme
    @State private var celebrateLeague = false

    var body: some View {
        ZStack {
            Color.fireBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    GuideDisclaimerBanner()

                    // Pre-league checklist
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

                    Divider()
                        .background(Color.fireTextSecondary.opacity(0.2))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 8)

                    // Elite Four
                    sectionHeader(title: "ELITE FOUR — PLAN EXACTO", icon: "trophy.fill")

                    VStack(spacing: 10) {
                        ForEach(bridge.eliteFour) { member in
                            eliteMemberCard(member)
                        }
                    }
                    .padding(.horizontal)

                    Divider()
                        .background(Color.fireTextSecondary.opacity(0.2))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 8)

                    // Postgame
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

                    // Tip
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.fireBlue)
                        Text("Rock Smash y Waterfall son HMs de postgame en Sevii Islands.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.fireBlue)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.fireBlue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding(.top, 8)
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
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.fireOrange)
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.fireOrange)
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
            HStack(spacing: 14) {
                // Status circle
                ZStack {
                    Circle()
                        .fill(completed ? Color.fireGreen.gradient : theme.accent.gradient)
                        .frame(width: 44, height: 44)

                    if completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(member.name)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(completed ? .fireTextSecondary : .fireTextPrimary)
                            .strikethrough(completed)

                        Spacer()

                        TypeBadge(text: "Nv. \(member.levels)", color: completed ? .fireGreen : theme.accent)
                    }

                    Text(member.strategy)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.fireTextSecondary)
                        .lineLimit(3)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(completed ? Color.fireGreen.opacity(0.08) : Color.fireCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(completed ? Color.fireGreen.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
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
            HStack(spacing: 12) {
                AnimatedCheck(isCompleted: isCompleted, size: 22)

                Text(text)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(isCompleted ? .fireTextSecondary : .fireTextPrimary)
                    .strikethrough(isCompleted, color: .fireTextSecondary)

                Spacer()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isCompleted ? Color.fireGreen.opacity(0.05) : Color.fireCard.opacity(0.5))
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
