//
//  PokedexDetailView.swift
//  pokemon guide
//
//  Vista de detalle — light mode.
//

import SwiftUI

struct PokedexDetailView: View {
    @EnvironmentObject var progress: ProgressManager
    let entry: PokemonEntry
    @State private var appeared = false
    @State private var spriteScale: CGFloat = 0.5

    private var status: PokemonStatus { progress.pokemonStatus(for: entry.id) }
    private var primaryColor: Color { entry.types.first?.color ?? .fireRed }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                heroCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -15)

                statusSection
                    .opacity(appeared ? 1 : 0)

                descriptionSection
                    .opacity(appeared ? 1 : 0)

                statsSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)

                locationSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)

                Spacer(minLength: 40)
            }
            .padding(.horizontal)
        }
        .background(Color.fireBg.ignoresSafeArea())
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.6)) { appeared = true }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) { spriteScale = 1.0 }
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(spacing: 14) {
            ZStack {
                // Soft colored circle bg
                Circle()
                    .fill(primaryColor.opacity(0.08))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(primaryColor.opacity(0.04))
                    .frame(width: 190, height: 190)

                AsyncImage(url: entry.spriteURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.interpolation(.none).resizable().scaledToFit()
                            .frame(width: 130, height: 130)
                            .shadow(color: primaryColor.opacity(0.15), radius: 10)
                    case .failure:
                        Image(systemName: "questionmark.circle.fill").font(.system(size: 50)).foregroundColor(.fireTextSecondary)
                    case .empty:
                        ProgressView().tint(.fireRed)
                    @unknown default: EmptyView()
                    }
                }
                .scaleEffect(spriteScale)
            }

            Text(entry.dexString)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.fireTextSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.black.opacity(0.05)))

            Text(entry.name)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.fireTextPrimary)

            HStack(spacing: 8) {
                ForEach(entry.types, id: \.self) { type in
                    HStack(spacing: 4) {
                        Image(systemName: type.icon).font(.system(size: 11))
                        Text(type.rawValue.capitalized).font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(type.color.gradient))
                }
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .softCard(cornerRadius: 24, tint: primaryColor, shadowRadius: 12)
    }

    // MARK: - Status

    private var statusSection: some View {
        HStack(spacing: 8) {
            ForEach(PokemonStatus.allCases, id: \.self) { s in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        progress.setPokemonStatus(for: entry.id, to: s)
                    }
                } label: {
                    VStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .fill(status == s ? s.color : s.color.opacity(0.08))
                                .frame(width: 36, height: 36)
                            Image(systemName: s.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(status == s ? .white : s.color)
                        }
                        Text(s.label)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(status == s ? s.color : .fireTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .softCard(cornerRadius: 18, tint: status.color)
    }

    // MARK: - Description

    private var descriptionSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "text.quote")
                .font(.system(size: 15))
                .foregroundColor(.fireOrange)
            Text(entry.description)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.fireTextSecondary)
                .italic()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .softCard(cornerRadius: 14)
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill").foregroundColor(.fireRed)
                Text("Estadísticas Base")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.fireTextPrimary)
                Spacer()
                Text("Total \(entry.stats.total)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.fireTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.black.opacity(0.05)))
            }

            statBar(label: "HP", value: entry.stats.hp, color: .fireGreen)
            statBar(label: "ATK", value: entry.stats.attack, color: .fireRed)
            statBar(label: "DEF", value: entry.stats.defense, color: .fireOrange)
            statBar(label: "SP.A", value: entry.stats.spAttack, color: .fireBlue)
            statBar(label: "SP.D", value: entry.stats.spDefense, color: Color(red: 0.45, green: 0.75, blue: 0.78))
            statBar(label: "VEL", value: entry.stats.speed, color: .fireYellow)
        }
        .padding(16)
        .softCard(cornerRadius: 18, tint: .fireRed, shadowRadius: 10)
    }

    private func statBar(label: String, value: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.fireTextSecondary)
                .frame(width: 32, alignment: .trailing)
            Text("\(value)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.fireTextPrimary)
                .frame(width: 30, alignment: .trailing)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.05))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.gradient)
                        .frame(width: appeared ? geo.size.width * CGFloat(value) / 255.0 : 0, height: 8)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: appeared)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.fireRed.opacity(0.08))
                    .frame(width: 38, height: 38)
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 16))
                    .foregroundColor(.fireRed)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("UBICACIÓN")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
                    .tracking(2)
                Text(entry.location)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.fireTextPrimary)
            }
            Spacer()
        }
        .padding(14)
        .softCard(cornerRadius: 16, tint: .fireRed)
    }
}

#Preview {
    NavigationStack {
        PokedexDetailView(entry: PokedexData.kanto[24])
            .environmentObject(ProgressManager())
    }
}
