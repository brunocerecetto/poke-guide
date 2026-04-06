//
//  CapturesView.swift
//  pokemon guide
//

import SwiftUI

struct CapturesView: View {
    var body: some View {
        ZStack {
            Color.fireBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(GameData.captures) { capture in
                        HStack(spacing: 14) {
                            // Pokéball icon
                            ZStack {
                                Circle()
                                    .fill(Color.fireRed.gradient)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "circle.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(capture.pokemon)
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.fireTextPrimary)

                                HStack(spacing: 8) {
                                    TypeBadge(text: capture.location, color: .fireGreen)
                                    Text(capture.note)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.fireTextSecondary)
                                }
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.fireCard)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Capturas Clave")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.automatic, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        CapturesView()
    }
}
