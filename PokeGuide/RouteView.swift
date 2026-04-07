//
//  RouteView.swift
//  pokemon guide
//

import SwiftUI

struct RouteView: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme

    var body: some View {
        ZStack {
            Color.fireBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    GuideDisclaimerBanner()
                        .padding(.top, 4)

                    // Route progress
                    routeProgress
                        .padding(.horizontal)
                        .padding(.top, 0)

                    ForEach(bridge.routeSections) { section in
                        sectionView(section)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Ruta Completa")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.automatic, for: .navigationBar)
    }

    private var routeProgress: some View {
        let totalSteps = bridge.routeSections.flatMap(\.steps).count
        let completedSteps = bridge.routeSections.flatMap(\.steps).filter { progress.isRouteStepCompleted($0.id) }.count

        return VStack(spacing: 6) {
            HStack {
                Text("Progreso de ruta")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
                Spacer()
                Text("\(completedSteps)/\(totalSteps)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.fireOrange)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.fireCard)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(colors: [theme.accent, theme.secondary], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: totalSteps > 0 ? geo.size.width * CGFloat(completedSteps) / CGFloat(totalSteps) : 0, height: 8)
                        .animation(.spring(response: 0.5), value: completedSteps)
                }
            }
            .frame(height: 8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.fireCard)
        )
    }

    private func sectionView(_ section: RouteSectionDTO) -> some View {
        let sectionCompleted = section.steps.allSatisfy { progress.isRouteStepCompleted($0.id) }

        return VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: sectionCompleted ? "flag.checkered" : "mappin.circle.fill")
                    .foregroundColor(sectionCompleted ? .fireGreen : .fireOrange)
                    .font(.system(size: 16))

                Text(section.title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(sectionCompleted ? .fireGreen : .fireTextPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .animation(.easeInOut, value: sectionCompleted)

            // Steps
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
            HStack(alignment: .top, spacing: 12) {
                // Timeline dot + line
                VStack(spacing: 0) {
                    Circle()
                        .fill(completed ? Color.fireGreen : Color.fireTextSecondary.opacity(0.4))
                        .frame(width: 10, height: 10)
                        .overlay(
                            Circle()
                                .fill(completed ? Color.fireGreen : Color.clear)
                                .frame(width: 4, height: 4)
                        )
                        .scaleEffect(completed ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: completed)

                    if !isLast {
                        Rectangle()
                            .fill(completed ? Color.fireGreen.opacity(0.3) : Color.fireTextSecondary.opacity(0.15))
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                }
                .frame(width: 10)

                // Content
                HStack(spacing: 10) {
                    AnimatedCheck(isCompleted: completed, size: 20)

                    Text(step.text)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(completed ? .fireTextSecondary : .fireTextPrimary)
                        .strikethrough(completed, color: .fireTextSecondary)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(completed ? Color.fireGreen.opacity(0.05) : Color.fireCard.opacity(0.5))
                )
            }
            .padding(.bottom, isLast ? 0 : 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        RouteView()
            .environmentObject(ProgressManager())
            .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
    }
}
