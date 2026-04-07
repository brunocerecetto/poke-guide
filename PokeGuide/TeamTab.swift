//
//  TeamTab.swift
//  PokeGuide
//
//  Equipo tab — recommended team (read-only) + my team (persistent) + captures.
//

import SwiftUI

struct TeamTab: View {
    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var gameConfig: GameConfig
    @EnvironmentObject var bridge: GameDataBridge
    @Environment(\.themeColors) private var theme

    @State private var selectedSlot: Int?
    @State private var showPicker = false

    private var customTeam: [PokemonEntry?] {
        progress.customTeamEntries(gameId: gameConfig.gameId)
    }

    private var filledTeam: [PokemonEntry] {
        customTeam.compactMap { $0 }
    }

    private var alreadyPicked: Set<Int> {
        Set(filledTeam.map(\.id))
    }

    var body: some View {
        NavigationStack {
            PageLayout(background: .clear) {
                VStack(spacing: KASpacing.lg) {
                    // Equipo Recomendado
                    NavigationLink {
                        TeamView()
                    } label: {
                        recommendedTeamCard
                    }
                    .padding(.horizontal)

                    // Mi Equipo
                    myTeamSection
                        .padding(.horizontal)

                    // Analysis
                    if !filledTeam.isEmpty {
                        coverageSection
                            .padding(.horizontal)

                        statsSection
                            .padding(.horizontal)

                        warningsSection
                            .padding(.horizontal)
                    }

                    // Capturas Clave
                    NavigationLink {
                        CapturesView()
                    } label: {
                        capturesCard
                    }
                    .padding(.horizontal)
                }
                .padding(.top, KASpacing.sm + KASpacing.xs)
            }
            .background(PixelBackground())
            .navigationTitle("Equipo")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPicker) {
                PokemonPickerSheet(
                    alreadyPickedDexNumbers: alreadyPicked,
                    gameVersion: gameConfig.version,
                    gameId: gameConfig.gameId,
                    onSelect: { entry in
                        guard let slot = selectedSlot else { return }
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            progress.setCustomTeamSlot(slot, dexNumber: entry.id)
                        }
                        showPicker = false
                    }
                )
            }
        }
    }

    // MARK: - Recommended Team Card

    private var recommendedTeamCard: some View {
        HStack(spacing: KASpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: KARadius.sm)
                    .fill(theme.accent.opacity(0.10))
                    .frame(width: 44, height: 44)
                Image(systemName: "star.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(theme.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Equipo Recomendado")
                    .font(KATypography.titleSm)
                    .foregroundColor(.onSurface)
                Text("\(bridge.team.count) pokémon + movesets")
                    .font(KATypography.labelSm)
                    .foregroundColor(.onSurfaceVariant)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.outlineVariant)
        }
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg, tint: theme.accent)
    }

    // MARK: - My Team Section

    private var myTeamSection: some View {
        VStack(spacing: KASpacing.sm + KASpacing.xs) {
            HStack(spacing: 6) {
                Image(systemName: "hammer.fill")
                    .foregroundColor(theme.accent)
                Text("Mi Equipo")
                    .font(KATypography.titleSm)
                    .foregroundColor(theme.accent)
                Spacer()
                Text("\(filledTeam.count)/6")
                    .font(KATypography.bodySmall)
                    .foregroundColor(.onSurfaceVariant)
            }

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    slotView(index: index)
                }
            }

            if filledTeam.isEmpty {
                Text("Tocá los slots para agregar Pokémon")
                    .font(KATypography.bodySmall)
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.top, KASpacing.xs)
            }
        }
        .padding()
        .softCard(cornerRadius: KARadius.lg)
    }

    private func slotView(index: Int) -> some View {
        let entry = index < customTeam.count ? customTeam[index] : nil

        return Button {
            if entry != nil {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    progress.setCustomTeamSlot(index, dexNumber: nil)
                }
            } else {
                selectedSlot = index
                showPicker = true
            }
        } label: {
            ZStack {
                Circle()
                    .fill(entry != nil ? theme.accent.opacity(0.08) : Color.surfaceContainerHighest)
                    .frame(width: 52, height: 52)

                if let entry {
                    AsyncImage(url: entry.spriteURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.interpolation(.none).resizable().scaledToFit()
                                .frame(width: 40, height: 40)
                        case .failure:
                            Image(systemName: "questionmark")
                                .foregroundColor(.onSurfaceVariant)
                        default:
                            ProgressView().controlSize(.small)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                }

                if entry != nil {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.kaPrimary.opacity(0.7))
                                .background(Circle().fill(Color.surfaceContainerLow).padding(2))
                        }
                        Spacer()
                    }
                    .frame(width: 52, height: 52)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Coverage

    private var coverageSection: some View {
        VStack(alignment: .leading, spacing: KASpacing.sm + KASpacing.xs) {
            KASectionHeader(title: "Cobertura ofensiva", icon: "burst.fill")

            let covered = TeamAnalysis.offensiveCoverage(for: filledTeam)
            let uncovered = PokemonType.allCases.filter { !covered.contains($0) }

            if !covered.isEmpty {
                coverageRow(label: "Super eficaz contra", types: covered, color: .success)
            }
            if !uncovered.isEmpty {
                coverageRow(label: "Sin cobertura contra", types: uncovered, color: .kaPrimary.opacity(0.7))
            }

            Spacer().frame(height: KASpacing.sm)

            KASectionHeader(title: "Debilidades defensivas", icon: "shield.slash.fill")

            let weaknesses = TeamAnalysis.defensiveWeaknesses(for: filledTeam)
            let resistances = TeamAnalysis.defensiveResistances(for: filledTeam)

            if !weaknesses.isEmpty {
                coverageRow(label: "Débil a", types: weaknesses, color: .primaryContainer)
            }
            if !resistances.isEmpty {
                coverageRow(label: "Resiste", types: resistances, color: .kaSecondaryContainer)
            }
        }
        .padding()
        .softCard(cornerRadius: KARadius.lg)
    }

    private func coverageRow(label: String, types: [PokemonType], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(KATypography.bodySmall)
                .foregroundColor(color)

            FlowLayout(spacing: KASpacing.xs) {
                ForEach(types, id: \.self) { type in
                    TypeBadge(text: type.rawValue.capitalized, color: type.color)
                }
            }
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: KASpacing.sm + KASpacing.xs) {
            KASectionHeader(title: "Estadísticas promedio", icon: "chart.bar.fill")

            let avg = TeamAnalysis.averageStats(for: filledTeam)
            VStack(spacing: KASpacing.sm) {
                statBar(label: "HP", value: avg.hp, color: .success)
                statBar(label: "ATK", value: avg.attack, color: theme.accent)
                statBar(label: "DEF", value: avg.defense, color: .primaryContainer)
                statBar(label: "SP.A", value: avg.spAttack, color: .kaSecondaryContainer)
                statBar(label: "SP.D", value: avg.spDefense, color: Color(red: 0.45, green: 0.75, blue: 0.78))
                statBar(label: "SPD", value: avg.speed, color: .kaYellow)
            }

            HStack {
                Spacer()
                Text("Total promedio: \(avg.total)")
                    .font(KATypography.titleSm)
                    .foregroundColor(theme.accent)
            }
        }
        .padding()
        .softCard(cornerRadius: KARadius.lg)
    }

    private func statBar(label: String, value: Int, color: Color) -> some View {
        HStack(spacing: KASpacing.sm) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurfaceVariant)
                .frame(width: 34, alignment: .trailing)
            Text("\(value)")
                .font(KATypography.bodySmall)
                .foregroundColor(.onSurface)
                .frame(width: 30, alignment: .trailing)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.surfaceContainerHighest)
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.gradient)
                        .frame(width: geo.size.width * CGFloat(value) / 255.0, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Warnings

    private var warningsSection: some View {
        let warnings = TeamAnalysis.generateWarnings(for: filledTeam)
        return Group {
            if !warnings.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    KASectionHeader(title: "Advertencias", icon: "exclamationmark.triangle.fill")

                    ForEach(warnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: KASpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.primaryContainer)
                                .padding(.top, 2)
                            Text(warning)
                                .font(KATypography.bodySmall)
                                .foregroundColor(.onSurface)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
                .softCard(cornerRadius: KARadius.lg, tint: .primaryContainer)
            }
        }
    }

    // MARK: - Captures Card

    private var capturesCard: some View {
        HStack(spacing: KASpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: KARadius.sm)
                    .fill(Color.success.opacity(0.10))
                    .frame(width: 44, height: 44)
                Image(systemName: "scope")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.success)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Capturas Clave")
                    .font(KATypography.titleSm)
                    .foregroundColor(.onSurface)
                Text("Pokémon esenciales para el run")
                    .font(KATypography.labelSm)
                    .foregroundColor(.onSurfaceVariant)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.outlineVariant)
        }
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg, tint: .success)
    }
}
