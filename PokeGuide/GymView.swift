//
//  GymView.swift
//  poke guide
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
            PageLayout("Gimnasios") {
                VStack(spacing: KASpacing.sm + KASpacing.xs) {
                    HStack(spacing: 6) {
                        ForEach(bridge.gyms) { gym in
                            Text(gym.badge)
                                .font(.title2)
                                .opacity(progress.isGymCompleted(gym.name) ? 1 : 0.2)
                                .scaleEffect(progress.isGymCompleted(gym.name) ? 1.0 : 0.8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: progress.isGymCompleted(gym.name))
                        }
                    }
                    .padding(.top, KASpacing.sm + KASpacing.xs)
                    .padding(.bottom, KASpacing.xs)

                    Text("\(progress.completedGyms.count) / \(bridge.gyms.count) badges")
                        .font(KATypography.bodySmall)
                        .foregroundColor(.onSurfaceVariant)

                    ForEach(Array(bridge.gyms.enumerated()), id: \.element.id) { index, gym in
                        gymCard(gym, index: index)
                            .padding(.horizontal)
                    }
                }
            }

            if celebrateAll {
                ConfettiView(trigger: celebrateAll)
            }
        }
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
            HStack(spacing: KASpacing.md) {
                ZStack {
                    Circle()
                        .fill(completed ? Color.success.gradient : Color.surfaceContainerHighest.gradient)
                        .frame(width: 44, height: 44)

                    if completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.onPrimary)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("\(index + 1)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.onSurfaceVariant)
                    }
                }

                VStack(alignment: .leading, spacing: KASpacing.xs) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(gym.badge)
                            .font(.body)
                        Text(gym.name)
                            .font(KATypography.titleMd)
                            .foregroundColor(completed ? .onSurfaceVariant : .onSurface)
                            .strikethrough(completed, color: .onSurfaceVariant)

                        Text(gym.leader)
                            .font(KATypography.titleSm)
                            .foregroundColor(.onSurfaceVariant)
                    }

                    HStack(spacing: KASpacing.sm) {
                        TypeBadge(text: "Nv. \(gym.levelRange)", color: .primaryContainer)

                        Text(gym.note)
                            .font(KATypography.labelSm)
                            .foregroundColor(.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }

                Spacer()
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
}

#Preview {
    NavigationStack {
        GymView()
            .environmentObject(ProgressManager())
            .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
    }
}
