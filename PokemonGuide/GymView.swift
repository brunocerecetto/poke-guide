//
//  GymView.swift
//  pokemon guide
//

import SwiftUI

struct GymView: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var bridge: GameDataBridge
    @State private var celebrateAll = false

    private var allCompleted: Bool {
        progress.completedGyms.count == bridge.gyms.count
    }

    var body: some View {
        ZStack {
            Color.fireBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    // Badge counter
                    HStack(spacing: 6) {
                        ForEach(bridge.gyms) { gym in
                            Text(gym.badge)
                                .font(.title2)
                                .opacity(progress.isGymCompleted(gym.name) ? 1 : 0.2)
                                .scaleEffect(progress.isGymCompleted(gym.name) ? 1.0 : 0.8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: progress.isGymCompleted(gym.name))
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 4)

                    Text("\(progress.completedGyms.count) / 8 badges")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.fireTextSecondary)

                    // Tip
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.fireOrange)
                        Text("Liga: entrá 52–55 mínimo, 55+ para margen cómodo")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.fireOrange)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.fireOrange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)

                    // Gym cards
                    ForEach(Array(bridge.gyms.enumerated()), id: \.element.id) { index, gym in
                        gymCard(gym, index: index)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }

            // Confetti
            if celebrateAll {
                ConfettiView(trigger: celebrateAll)
            }
        }
        .navigationTitle("Gimnasios")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.automatic, for: .navigationBar)
        .task(id: celebrateAll) {
            guard celebrateAll else { return }
            try? await Task.sleep(for: .seconds(2))
            celebrateAll = false
        }
    }

    private func gymCard(_ gym: GymDTO, index: Int) -> some View {
        let completed = progress.isGymCompleted(gym.name)

        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                progress.toggleGym(gym.name)
            }
            if progress.completedGyms.count == bridge.gyms.count {
                celebrateAll = true
            }
        } label: {
            HStack(spacing: 14) {
                // Badge number
                ZStack {
                    Circle()
                        .fill(completed ? Color.fireGreen.gradient : Color.fireCard.gradient)
                        .frame(width: 44, height: 44)

                    if completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("\(index + 1)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.fireTextSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(gym.badge)
                            .font(.body)
                        Text(gym.name)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(completed ? .fireTextSecondary : .fireTextPrimary)
                            .strikethrough(completed, color: .fireTextSecondary)

                        Text(gym.leader)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.fireTextSecondary)
                    }

                    HStack(spacing: 8) {
                        TypeBadge(text: "Nv. \(gym.levelRange)", color: .fireOrange)

                        Text(gym.note)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.fireTextSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()
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
}

#Preview {
    NavigationStack {
        GymView()
            .environmentObject(ProgressManager())
            .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
    }
}
