//
//  TipsView.swift
//  pokemon guide
//

import SwiftUI

struct TipsView: View {
    var body: some View {
        ZStack {
            Color.fireBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    GuideDisclaimerBanner()

                    ForEach(GameData.tips) { tip in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(tip.pokemon)
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.fireTextPrimary)

                            Text(tip.rule)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.fireTextSecondary)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.fireCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.fireYellow.opacity(0.15), lineWidth: 1)
                                )
                        )
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
    }
}
