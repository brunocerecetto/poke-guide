//
//  PokeballProgress.swift
//  PokeGuide
//
//  Circular progress ring with animated percentage.
//

import SwiftUI

struct PokeballProgress: View {
    let progress: Double
    @Environment(\.themeColors) private var theme
    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.outlineVariant.opacity(0.15), lineWidth: 10)
                .frame(width: 130, height: 130)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: theme.gradientColors,
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 130, height: 130)
                .rotationEffect(.degrees(-90))
                .shadow(color: theme.accent.opacity(0.2), radius: 6)

            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(KATypography.headlineLg)
                    .foregroundColor(theme.accent)
                Text("completado")
                    .font(KATypography.labelXs)
                    .foregroundColor(.onSurfaceVariant)
                    .textCase(.uppercase)
                    .tracking(1.5)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { animatedProgress = progress }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) { animatedProgress = newValue }
        }
        .onDisappear {
            animatedProgress = 0
        }
    }
}
