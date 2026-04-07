//
//  GuideDisclaimerBanner.swift
//  PokeGuide
//
//  Info banner shown when game doesn't match the optimized guide.
//

import SwiftUI

struct GuideDisclaimerBanner: View {
    @EnvironmentObject var gameConfig: GameConfig
    @Environment(\.themeColors) private var theme

    var isMatchingGuide: Bool {
        gameConfig.gameId == "fireRed" && gameConfig.starterDex == 7
    }

    var body: some View {
        if !isMatchingGuide {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.accent)

                Text("Esta guía está optimizada para **Fire Red + Squirtle**. Los pasos son similares pero pueden variar exclusivos y evoluciones.")
                    .font(KATypography.labelSm)
                    .foregroundColor(.onSurfaceVariant)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(KASpacing.sm + KASpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: KARadius.sm)
                    .fill(Color.surfaceContainerHighest)
            )
            .ghostBorder(cornerRadius: KARadius.sm)
            .padding(.horizontal)
        }
    }
}
