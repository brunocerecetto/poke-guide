//
//  RouteView.swift
//  poke guide
//

import SwiftUI

struct RouteView: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme

    var body: some View {
        PageLayout("Ruta Completa") {
            VStack(spacing: KASpacing.md) {
                routeProgress
                    .padding(.horizontal)
                    .padding(.top, KASpacing.xs)

                ForEach(bridge.routeSections) { section in
                    sectionView(section)
                }
            }
        }
    }

    private var routeProgress: some View {
        let totalSteps = bridge.routeSections.flatMap(\.steps).count
        let completedSteps = bridge.routeSections.flatMap(\.steps).filter { progress.isRouteStepCompleted($0.id) }.count

        return VStack(spacing: 6) {
            HStack {
                Text("Progreso de ruta")
                    .font(KATypography.bodySmall)
                    .foregroundColor(.onSurfaceVariant)
                Spacer()
                Text("\(completedSteps)/\(totalSteps)")
                    .font(KATypography.titleSm)
                    .foregroundColor(theme.accent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceContainerHighest)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(colors: theme.gradientColors, startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: totalSteps > 0 ? geo.size.width * CGFloat(completedSteps) / CGFloat(totalSteps) : 0, height: 8)
                        .animation(.spring(response: 0.5), value: completedSteps)
                }
            }
            .frame(height: 8)
        }
        .padding(KASpacing.sm + KASpacing.xs)
        .softCard(cornerRadius: KARadius.lg)
    }

    private func sectionView(_ section: RouteSectionDTO) -> some View {
        let sectionCompleted = section.steps.allSatisfy { progress.isRouteStepCompleted($0.id) }

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: KASpacing.sm) {
                Image(systemName: sectionCompleted ? "flag.checkered" : "mappin.circle.fill")
                    .foregroundColor(sectionCompleted ? .success : theme.accent)
                    .font(.system(size: 16))

                Text(section.title)
                    .font(KATypography.titleSm)
                    .foregroundColor(sectionCompleted ? .success : .onSurface)
            }
            .padding(.horizontal, KASpacing.md)
            .padding(.vertical, 10)
            .animation(.easeInOut, value: sectionCompleted)

            VStack(spacing: 0) {
                ForEach(Array(section.steps.enumerated()), id: \.element.id) { index, step in
                    stepRow(step, isLast: index == section.steps.count - 1)
                }
            }
            .padding(.horizontal)
        }
    }

    private func stepRow(_ step: RouteStepDTO, isLast: Bool) -> some View {
        let completed = progress.isRouteStepCompleted(step.id)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                progress.toggleRouteStep(step.id)
            }
        } label: {
            HStack(alignment: .top, spacing: KASpacing.sm + KASpacing.xs) {
                VStack(spacing: 0) {
                    Circle()
                        .fill(completed ? Color.success : Color.outlineVariant.opacity(0.4))
                        .frame(width: 10, height: 10)
                        .scaleEffect(completed ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: completed)

                    if !isLast {
                        Rectangle()
                            .fill(completed ? Color.success.opacity(0.3) : Color.outlineVariant.opacity(0.2))
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                }
                .frame(width: 10)

                HStack(spacing: 10) {
                    AnimatedCheck(isCompleted: completed, size: 20)

                    Text(step.text)
                        .font(KATypography.bodySmall)
                        .foregroundColor(completed ? .onSurfaceVariant : .onSurface)
                        .strikethrough(completed, color: .onSurfaceVariant)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }
                .padding(.vertical, KASpacing.sm)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: KARadius.sm)
                        .fill(completed ? Color.success.opacity(0.04) : Color.surfaceContainerLow)
                )
            }
            .padding(.bottom, isLast ? 0 : KASpacing.xs)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(step.text)
        .accessibilityHint(completed ? "Completado" : "No completado")
    }
}

#Preview {
    NavigationStack {
        RouteView()
            .environmentObject(ProgressManager())
            .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
    }
}
