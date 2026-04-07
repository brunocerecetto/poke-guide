//
//  MyTeamDetailView.swift
//  PokeGuide
//
//  Unified detail view for both recommended and custom teams.
//  Recommended = read-only pokemon with moveset info.
//  Custom = editable slots with picker + dynamic analysis.
//

import SwiftUI

// MARK: - Team Mode

enum TeamMode {
    case recommended(members: [TeamMemberDTO])
    case custom
}

// MARK: - Detail View

struct MyTeamDetailView: View {
    var mode: TeamMode = .custom

    @EnvironmentObject var progress: ProgressManager
    @EnvironmentObject var gameConfig: GameConfig
    @Environment(\.themeColors) private var theme

    @State private var selectedSlot: Int?
    @State private var showPicker = false

    private var isEditable: Bool {
        if case .custom = mode { return true }
        return false
    }

    private var title: String {
        switch mode {
        case .recommended: return "Equipo Recomendado"
        case .custom: return "Mi Equipo"
        }
    }

    // Pokemon entries for analysis
    private var entries: [PokemonEntry] {
        switch mode {
        case .recommended(let members):
            let all = PokemonLoader.entries(forGameId: gameConfig.gameId)
            return members.compactMap { m in all.first(where: { $0.id == m.dexNumber }) }
        case .custom:
            return progress.customTeamEntries(gameId: gameConfig.gameId).compactMap { $0 }
        }
    }

    private var customTeam: [PokemonEntry?] {
        progress.customTeamEntries(gameId: gameConfig.gameId)
    }

    private var alreadyPicked: Set<Int> {
        Set(entries.map(\.id))
    }

    var body: some View {
        PageLayout(title) {
            VStack(spacing: KASpacing.lg) {
                // Pokemon grid
                slotsSection

                // Analysis (when team has members)
                if !entries.isEmpty {
                    coverageSection
                    statsSection
                    warningsSection
                }
            }
            .padding(.horizontal)
        }
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

    // MARK: - Slots

    private var slotsSection: some View {
        VStack(spacing: KASpacing.sm + KASpacing.xs) {
            switch mode {
            case .recommended(let members):
                recommendedGrid(members)
            case .custom:
                customGrid
            }
        }
        .padding()
        .softCard(cornerRadius: KARadius.lg)
    }

    private func recommendedGrid(_ members: [TeamMemberDTO]) -> some View {
        let rows = stride(from: 0, to: members.count, by: 3).map {
            Array(members[$0..<min($0 + 3, members.count)])
        }
        return VStack(spacing: 10) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 10) {
                    ForEach(row) { member in
                        NavigationLink {
                            TeamMemberDetailView(member: member)
                        } label: {
                            VStack(spacing: KASpacing.xs) {
                                spriteCircle(dexNumber: member.dexNumber, emoji: member.emoji)
                                Text(member.name)
                                    .font(KATypography.labelXs)
                                    .foregroundColor(.onSurfaceVariant)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Text("Tocá un Pokémon para ver su moveset")
                .font(KATypography.bodySmall)
                .foregroundColor(.onSurfaceVariant)
                .padding(.top, KASpacing.xs)
        }
    }

    private var customGrid: some View {
        VStack(spacing: 10) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { col in
                        customSlotView(index: row * 3 + col)
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            if entries.isEmpty {
                Text("Tocá los slots para agregar Pokémon")
                    .font(KATypography.bodySmall)
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.top, KASpacing.xs)
            }
        }
    }

    private func customSlotView(index: Int) -> some View {
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
            VStack(spacing: KASpacing.xs) {
                ZStack {
                    Circle()
                        .fill(entry != nil ? theme.accent.opacity(0.08) : Color.surfaceContainerHighest)
                        .frame(width: 52, height: 52)

                    if let entry {
                        PokemonSpriteView(url: entry.spriteURL, size: 40)
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
                                    .foregroundColor(theme.accent.opacity(0.7))
                                    .background(Circle().fill(Color.surfaceContainerLow).padding(2))
                            }
                            Spacer()
                        }
                        .frame(width: 52, height: 52)
                    }
                }

                Text(entry?.name ?? "")
                    .font(KATypography.labelXs)
                    .foregroundColor(.onSurfaceVariant)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Shared Components

    private func spriteCircle(dexNumber: Int, emoji: String) -> some View {
        ZStack {
            Circle()
                .fill(theme.accent.opacity(0.08))
                .frame(width: 52, height: 52)

            PokemonSpriteView(
                url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(dexNumber).png"),
                size: 40,
                fallbackEmoji: emoji
            )
        }
    }

    // MARK: - Coverage

    private var coverageSection: some View {
        VStack(alignment: .leading, spacing: KASpacing.sm + KASpacing.xs) {
            KASectionHeader(title: "Cobertura ofensiva", icon: "burst.fill")

            let covered = TeamAnalysis.offensiveCoverage(for: entries)
            let uncovered = PokemonType.allCases.filter { !covered.contains($0) }

            if !covered.isEmpty {
                coverageRow(label: "Super eficaz contra", types: covered, color: .success)
            }
            if !uncovered.isEmpty {
                coverageRow(label: "Sin cobertura contra", types: uncovered, color: theme.accent.opacity(0.7))
            }

            Spacer().frame(height: KASpacing.sm)

            KASectionHeader(title: "Debilidades defensivas", icon: "shield.slash.fill")

            let weaknesses = TeamAnalysis.defensiveWeaknesses(for: entries)
            let resistances = TeamAnalysis.defensiveResistances(for: entries)

            if !weaknesses.isEmpty {
                coverageRow(label: "Débil a", types: weaknesses, color: theme.secondary)
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

            let avg = TeamAnalysis.averageStats(for: entries)
            VStack(spacing: KASpacing.sm) {
                statBar(label: "HP", value: avg.hp, color: .success)
                statBar(label: "ATK", value: avg.attack, color: theme.accent)
                statBar(label: "DEF", value: avg.defense, color: theme.secondary)
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
        let warnings = TeamAnalysis.generateWarnings(for: entries)
        return Group {
            if !warnings.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    KASectionHeader(title: "Advertencias", icon: "exclamationmark.triangle.fill")

                    ForEach(warnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: KASpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(theme.secondary)
                                .padding(.top, 2)
                            Text(warning)
                                .font(KATypography.bodySmall)
                                .foregroundColor(.onSurface)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
                .softCard(cornerRadius: KARadius.lg, tint: theme.secondary)
            }
        }
    }
}
