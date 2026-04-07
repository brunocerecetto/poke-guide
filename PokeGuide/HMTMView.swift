//
//  HMTMView.swift
//  poke guide
//

import SwiftUI

struct HMTMView: View {
    @EnvironmentObject var bridge: GameDataBridge
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("HMs").tag(0)
                Text("TMs").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            GuideDisclaimerBanner()
                .padding(.horizontal)

            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 0) {
                        if selectedTab == 0 {
                            hmList
                        } else {
                            tmList
                        }

                        Spacer(minLength: 0)

                        FanDisclaimer()
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle("HMs & TMs")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.automatic, for: .navigationBar)
    }

    private var hmList: some View {
        VStack(spacing: KASpacing.sm) {
            ForEach(bridge.hmEntries) { entry in
                HStack(spacing: KASpacing.sm + KASpacing.xs) {
                    Text(entry.hm)
                        .font(KATypography.titleSm)
                        .foregroundColor(.kaSecondaryContainer)
                        .frame(width: 80, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.pokemon)
                            .font(KATypography.titleSm)
                            .foregroundColor(.onSurface)
                        Text(entry.location)
                            .font(KATypography.bodySmall)
                            .foregroundColor(.onSurfaceVariant)
                    }

                    Spacer()
                }
                .padding(KASpacing.sm + KASpacing.xs)
                .softCard(cornerRadius: KARadius.lg)
                .padding(.horizontal)
            }

        }
        .padding(.top, KASpacing.xs)
    }

    private var tmList: some View {
        VStack(spacing: KASpacing.sm) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.kaYellow)
                    .font(.system(size: 12))
                Text("Prioridad: Thunderbolt > Ice Beam > Flamethrower")
                    .font(KATypography.labelSm)
                    .foregroundColor(.kaYellow)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.surfaceContainerHighest)
            .clipShape(RoundedRectangle(cornerRadius: KARadius.sm))
            .padding(.horizontal)

            ForEach(bridge.tmEntries) { entry in
                HStack(spacing: KASpacing.sm + KASpacing.xs) {
                    VStack(alignment: .leading, spacing: KASpacing.xs) {
                        HStack {
                            Text(entry.tm)
                                .font(KATypography.titleSm)
                                .foregroundColor(.kaPrimary)

                            Spacer()

                            TypeBadge(text: entry.target, color: .kaSecondaryContainer)
                        }
                        Text(entry.origin)
                            .font(KATypography.bodySmall)
                            .foregroundColor(.onSurfaceVariant)
                    }
                }
                .padding(KASpacing.sm + KASpacing.xs)
                .softCard(cornerRadius: KARadius.lg)
                .padding(.horizontal)
            }

        }
        .padding(.top, KASpacing.xs)
    }
}

#Preview {
    NavigationStack {
        HMTMView()
            .environmentObject(GameDataBridge(gameId: "fireRed", starterDex: 7, context: nil))
    }
}
