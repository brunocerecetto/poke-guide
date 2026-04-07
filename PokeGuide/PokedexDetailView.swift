//
//  PokedexDetailView.swift
//  poke guide
//
//  Vista de detalle — "The Kinetic Archive" editorial style.
//

import SwiftUI

struct PokedexDetailView: View {
    @EnvironmentObject var progress: ProgressManager
    @Environment(\.themeColors) private var theme
    let entry: PokemonEntry
    @State private var appeared = false
    @State private var spriteScale: CGFloat = 0.5

    private var status: PokemonStatus { progress.pokemonStatus(for: entry.id) }
    private var primaryColor: Color { entry.types.first?.color ?? theme.accent }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: KASpacing.md) {
                heroCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -15)

                statusSection
                    .opacity(appeared ? 1 : 0)

                if !entry.description.isEmpty {
                    descriptionSection
                        .opacity(appeared ? 1 : 0)
                }

                statsSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)

                if !entry.location.isEmpty {
                    locationSection
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal)
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.6)) { appeared = true }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) { spriteScale = 1.0 }
        }
    }

    // MARK: - Hero (Editorial: oversized dex number)

    private var heroCard: some View {
        VStack(spacing: KASpacing.md) {
            ZStack {
                // Glassmorphic pedestal with type color bleed
                Circle()
                    .fill(primaryColor.opacity(0.06))
                    .frame(width: 190, height: 190)

                Circle()
                    .fill(primaryColor.opacity(0.04))
                    .frame(width: 220, height: 220)

                AsyncImage(url: entry.spriteURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.interpolation(.none).resizable().scaledToFit()
                            .frame(width: 130, height: 130)
                    case .failure:
                        Image(systemName: "questionmark.circle.fill").font(.system(size: 50)).foregroundColor(.onSurfaceVariant)
                    case .empty:
                        ProgressView().tint(theme.accent)
                    @unknown default: EmptyView()
                    }
                }
                .scaleEffect(spriteScale)
            }

            // Dramatic scale shift: oversized dex number
            Text(entry.dexString)
                .font(KATypography.displayLg)
                .foregroundColor(.onSurface.opacity(0.08))
                .tightTracking(56)
                .overlay(alignment: .center) {
                    Text(entry.name)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.onSurface)
                }

            // Type badges (10% opacity style)
            HStack(spacing: KASpacing.sm) {
                ForEach(entry.types, id: \.self) { type in
                    HStack(spacing: KASpacing.xs) {
                        Image(systemName: type.icon).font(.system(size: 11))
                        Text(type.rawValue.capitalized).font(KATypography.titleSm)
                    }
                    .foregroundColor(type.color)
                    .padding(.horizontal, KASpacing.md)
                    .padding(.vertical, KASpacing.sm)
                    .background(Capsule().fill(type.color.opacity(0.10)))
                }
            }
        }
        .padding(.vertical, KASpacing.lg)
        .frame(maxWidth: .infinity)
        .glassmorphism(typeColor: primaryColor, cornerRadius: KARadius.lg)
        .ghostBorder(cornerRadius: KARadius.lg)
        .clipShape(RoundedRectangle(cornerRadius: KARadius.lg))
    }

    // MARK: - Status

    private var statusSection: some View {
        HStack(spacing: KASpacing.sm) {
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
                                .foregroundColor(status == s ? .onPrimary : s.color)
                        }
                        Text(s.label)
                            .font(KATypography.labelXs)
                            .foregroundColor(status == s ? s.color : .onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg, tint: status.color)
    }

    // MARK: - Description

    private var descriptionSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "text.quote")
                .font(.system(size: 15))
                .foregroundColor(theme.accent)
            Text(entry.description)
                .font(KATypography.bodyMd)
                .foregroundColor(.onSurfaceVariant)
                .italic()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg)
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: KASpacing.sm + KASpacing.xs) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill").foregroundColor(theme.accent)
                Text("Estadísticas Base")
                    .font(KATypography.titleSm)
                    .foregroundColor(.onSurface)
                Spacer()
                Text("Total \(entry.stats.total)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.horizontal, KASpacing.sm)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.surfaceContainerHighest))
            }

            statBar(label: "HP", value: entry.stats.hp, color: .success)
            statBar(label: "ATK", value: entry.stats.attack, color: theme.accent)
            statBar(label: "DEF", value: entry.stats.defense, color: .primaryContainer)
            statBar(label: "SP.A", value: entry.stats.spAttack, color: .kaSecondaryContainer)
            statBar(label: "SP.D", value: entry.stats.spDefense, color: Color(red: 0.45, green: 0.75, blue: 0.78))
            statBar(label: "VEL", value: entry.stats.speed, color: .kaYellow)
        }
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg, tint: theme.accent)
    }

    private func statBar(label: String, value: Int, color: Color) -> some View {
        HStack(spacing: KASpacing.sm) {
            Text(label)
                .font(KATypography.labelSm)
                .foregroundColor(.onSurfaceVariant)
                .frame(width: 32, alignment: .trailing)
            Text("\(value)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurface)
                .frame(width: 30, alignment: .trailing)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceContainerHighest)
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
        VStack(spacing: 0) {
            HStack(spacing: KASpacing.sm + KASpacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(theme.accent.opacity(0.08))
                        .frame(width: 38, height: 38)
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 16))
                        .foregroundColor(theme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("UBICACIÓN")
                        .font(KATypography.labelXs)
                        .foregroundColor(.onSurfaceVariant)
                        .tracking(2)
                    Text(entry.location)
                        .font(KATypography.titleMd)
                        .foregroundColor(.onSurface)
                }
                Spacer()

                availabilityBadge
            }

            if let version = entry.availability {
                HStack(spacing: KASpacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 9))
                    Text("Solo disponible en \(version.shortName)")
                        .font(KATypography.labelSm)
                }
                .foregroundColor(version.accentColor)
                .padding(.top, KASpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 50)
            }
        }
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg, tint: theme.accent)
    }

    private var availabilityBadge: some View {
        Group {
            if let version = entry.availability {
                Text(version == .fireRed ? "FR" : "LG")
                    .font(KATypography.labelXs)
                    .foregroundColor(.onPrimary)
                    .padding(.horizontal, KASpacing.sm)
                    .padding(.vertical, KASpacing.xs)
                    .background(Capsule().fill(version.accentColor))
            } else {
                HStack(spacing: 3) {
                    Text("FR")
                        .font(KATypography.labelXs)
                        .foregroundColor(.kaPrimary)
                    Text("·")
                        .foregroundColor(.onSurfaceVariant)
                    Text("LG")
                        .font(KATypography.labelXs)
                        .foregroundColor(Color(red: 0.18, green: 0.65, blue: 0.32))
                }
                .padding(.horizontal, KASpacing.sm)
                .padding(.vertical, KASpacing.xs)
                .background(Capsule().fill(Color.surfaceContainerHighest))
            }
        }
    }
}

#Preview {
    NavigationStack {
        PokedexDetailView(entry: PokedexData.kanto[24])
            .environmentObject(ProgressManager())
    }
}
