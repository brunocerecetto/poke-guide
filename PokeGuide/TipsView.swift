//
//  TipsView.swift
//  poke guide
//

import SwiftUI

struct TipsView: View {
    @EnvironmentObject var bridge: GameDataBridge

    var body: some View {
        ZStack {
            Color.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: KASpacing.md) {
                    GuideDisclaimerBanner()

                    ForEach(bridge.tips) { tip in
                        VStack(alignment: .leading, spacing: KASpacing.sm) {
                            Text(tip.pokemon)
                                .font(KATypography.titleMd)
                                .foregroundColor(.onSurface)

                            Text(tip.rule)
                                .font(KATypography.bodySmall)
                                .foregroundColor(.onSurfaceVariant)
                        }
                        .padding(KASpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .softCard(cornerRadius: KARadius.lg)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Tips")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.automatic, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        TipsView()
            .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
    }
}
