//
//  CapturesView.swift
//  poke guide
//

import SwiftUI

struct CapturesView: View {
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme

    var body: some View {
        PageLayout("Capturas Clave") {
            VStack(spacing: KASpacing.md) {
                ForEach(bridge.captures) { capture in
                    HStack(spacing: KASpacing.md) {
                        ZStack {
                            Circle()
                                .fill(theme.accent.gradient)
                                .frame(width: 44, height: 44)
                            Image(systemName: "circle.circle.fill")
                                .font(.title3)
                                .foregroundColor(.onPrimary)
                        }

                        VStack(alignment: .leading, spacing: KASpacing.xs) {
                            Text(capture.pokemon)
                                .font(KATypography.titleMd)
                                .foregroundColor(.onSurface)

                            HStack(spacing: KASpacing.sm) {
                                TypeBadge(text: capture.location, color: .success)
                                Text(capture.note)
                                    .font(KATypography.bodySmall)
                                    .foregroundColor(.onSurfaceVariant)
                            }
                        }

                        Spacer()
                    }
                    .padding(KASpacing.md)
                    .softCard(cornerRadius: KARadius.lg)
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CapturesView()
            .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
    }
}
