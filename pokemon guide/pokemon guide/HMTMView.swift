//
//  HMTMView.swift
//  pokemon guide
//

import SwiftUI

struct HMTMView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Color.fireBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Segmented picker
                Picker("", selection: $selectedTab) {
                    Text("HMs").tag(0)
                    Text("TMs").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                ScrollView {
                    if selectedTab == 0 {
                        hmList
                    } else {
                        tmList
                    }
                }
            }
        }
        .navigationTitle("HMs & TMs")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.automatic, for: .navigationBar)
    }

    private var hmList: some View {
        VStack(spacing: 8) {
            ForEach(GameData.hms) { entry in
                HStack(spacing: 12) {
                    Text(entry.hm)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.fireBlue)
                        .frame(width: 80, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.pokemon)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.fireTextPrimary)
                        Text(entry.location)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.fireTextSecondary)
                    }

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.fireCard)
                )
                .padding(.horizontal)
            }

            Spacer(minLength: 30)
        }
        .padding(.top, 4)
    }

    private var tmList: some View {
        VStack(spacing: 8) {
            // Priority tip
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.fireYellow)
                    .font(.system(size: 12))
                Text("Prioridad: Thunderbolt > Ice Beam > Flamethrower")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.fireYellow)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.fireYellow.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)

            ForEach(GameData.tms) { entry in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.tm)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.purple)

                            Spacer()

                            TypeBadge(text: entry.target, color: .fireBlue)
                        }
                        Text(entry.origin)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.fireTextSecondary)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.fireCard)
                )
                .padding(.horizontal)
            }

            Spacer(minLength: 30)
        }
        .padding(.top, 4)
    }
}

#Preview {
    NavigationStack {
        HMTMView()
    }
}
