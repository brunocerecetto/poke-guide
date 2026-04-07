//
//  TeamBuilderView.swift
//  PokeGuide
//
//  Constructor de equipo con análisis de cobertura de tipos.
//

import SwiftUI

struct TeamBuilderView: View {
    @EnvironmentObject var gameConfig: GameConfig
    @Environment(\.themeColors) private var theme

    @State private var team: [PokemonEntry?] = Array(repeating: nil, count: 6)
    @State private var selectedSlot: Int?
    @State private var showPicker = false

    private var filledTeam: [PokemonEntry] { team.compactMap { $0 } }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                teamSlots
                    .padding(.horizontal)

                if !filledTeam.isEmpty {
                    typeCoverageSection
                        .padding(.horizontal)

                    statAveragesSection
                        .padding(.horizontal)

                    warningsSection
                        .padding(.horizontal)
                }

                if filledTeam.isEmpty {
                    emptyState
                        .padding(.top, 40)
                }

                Spacer(minLength: 30)
            }
            .padding(.top, 12)
        }
        .background(Color.fireBg.ignoresSafeArea())
        .navigationTitle("Team Builder")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showPicker) {
            PokemonPickerSheet(
                team: $team,
                slotIndex: selectedSlot ?? 0,
                gameVersion: gameConfig.version,
                gameId: gameConfig.gameId,
                onSelect: { entry in
                    guard let slot = selectedSlot else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        team[slot] = entry
                    }
                    showPicker = false
                }
            )
        }
    }

    // MARK: - Team Slots

    private var teamSlots: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "person.3.fill")
                    .foregroundColor(theme.accent)
                Text("Tu equipo")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(theme.accent)
                Spacer()
                Text("\(filledTeam.count)/6")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
            }

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    slotView(index: index)
                }
            }
        }
        .padding()
        .softCard(cornerRadius: 16)
    }

    private func slotView(index: Int) -> some View {
        Button {
            if team[index] != nil {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    team[index] = nil
                }
            } else {
                selectedSlot = index
                showPicker = true
            }
        } label: {
            ZStack {
                Circle()
                    .fill(team[index] != nil
                        ? theme.accent.opacity(0.08)
                        : Color.fireGray.opacity(0.6))
                    .frame(width: 52, height: 52)

                if let entry = team[index] {
                    AsyncImage(url: entry.spriteURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.interpolation(.none).resizable().scaledToFit()
                                .frame(width: 40, height: 40)
                        case .failure:
                            Image(systemName: "questionmark")
                                .foregroundColor(.fireTextSecondary)
                        default:
                            ProgressView().controlSize(.small)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.fireTextSecondary.opacity(0.5))
                }

                // Remove badge
                if team[index] != nil {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.fireRed.opacity(0.7))
                                .background(Circle().fill(.white).padding(2))
                        }
                        Spacer()
                    }
                    .frame(width: 52, height: 52)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(theme.accent.opacity(0.3))

            Text("Armá tu equipo ideal")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.fireTextPrimary)

            Text("Tocá los slots de arriba para agregar Pokémon y ver el análisis de cobertura de tipos.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.fireTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Type Coverage

    private var typeCoverageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FireRedSectionHeader(title: "Cobertura ofensiva", icon: "burst.fill")

            let covered = offensiveCoverage()
            let uncovered = PokemonType.allCases.filter { !covered.contains($0) }

            if !covered.isEmpty {
                coverageRow(label: "Super eficaz contra", types: covered, color: .fireGreen)
            }
            if !uncovered.isEmpty {
                coverageRow(label: "Sin cobertura contra", types: uncovered, color: .fireRed.opacity(0.7))
            }

            Divider().padding(.vertical, 4)

            FireRedSectionHeader(title: "Debilidades defensivas", icon: "shield.slash.fill")

            let teamWeaknesses = defensiveWeaknesses()
            let teamResistances = defensiveResistances()

            if !teamWeaknesses.isEmpty {
                coverageRow(label: "Débil a", types: teamWeaknesses, color: .fireOrange)
            }
            if !teamResistances.isEmpty {
                coverageRow(label: "Resiste", types: teamResistances, color: .fireBlue)
            }
        }
        .padding()
        .softCard(cornerRadius: 16)
    }

    private func coverageRow(label: String, types: [PokemonType], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(color)

            FlowLayout(spacing: 4) {
                ForEach(types, id: \.self) { type in
                    TypeBadge(text: type.rawValue.capitalized, color: type.color)
                }
            }
        }
    }

    // MARK: - Stat Averages

    private var statAveragesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FireRedSectionHeader(title: "Estadísticas promedio", icon: "chart.bar.fill")

            let avg = averageStats()
            VStack(spacing: 8) {
                statBar(label: "HP", value: avg.hp, max: 255, color: .fireGreen)
                statBar(label: "ATK", value: avg.attack, max: 255, color: .fireRed)
                statBar(label: "DEF", value: avg.defense, max: 255, color: .fireOrange)
                statBar(label: "SP.A", value: avg.spAttack, max: 255, color: .fireBlue)
                statBar(label: "SP.D", value: avg.spDefense, max: 255, color: Color.purple.opacity(0.7))
                statBar(label: "SPD", value: avg.speed, max: 255, color: .fireYellow)
            }

            HStack {
                Spacer()
                Text("Total promedio: \(avg.total)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(theme.accent)
            }
        }
        .padding()
        .softCard(cornerRadius: 16)
    }

    private func statBar(label: String, value: Int, max: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.fireTextSecondary)
                .frame(width: 34, alignment: .trailing)

            Text("\(value)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.fireTextPrimary)
                .frame(width: 30, alignment: .trailing)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.fireGray)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.gradient)
                        .frame(width: geo.size.width * CGFloat(value) / CGFloat(max), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Warnings

    private var warningsSection: some View {
        let warnings = generateWarnings()
        return Group {
            if !warnings.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    FireRedSectionHeader(title: "Advertencias", icon: "exclamationmark.triangle.fill")

                    ForEach(warnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.fireOrange)
                                .padding(.top, 2)

                            Text(warning)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.fireTextPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
                .softCard(cornerRadius: 16, tint: .fireOrange)
            }
        }
    }

    // MARK: - Analysis Logic

    private func offensiveCoverage() -> [PokemonType] {
        var covered = Set<PokemonType>()
        for member in filledTeam {
            for attackType in member.types {
                for target in TypeEffectiveness.superEffective(attackType) {
                    covered.insert(target)
                }
            }
        }
        return PokemonType.allCases.filter { covered.contains($0) }
    }

    private func defensiveWeaknesses() -> [PokemonType] {
        var weakCounts: [PokemonType: Int] = [:]
        for member in filledTeam {
            for weakness in TypeEffectiveness.weaknesses(of: member.types) {
                weakCounts[weakness, default: 0] += 1
            }
        }
        // Show types that at least half the team is weak to
        let threshold = max(1, filledTeam.count / 2)
        return PokemonType.allCases.filter { (weakCounts[$0] ?? 0) >= threshold }
    }

    private func defensiveResistances() -> [PokemonType] {
        var resistCounts: [PokemonType: Int] = [:]
        for member in filledTeam {
            for resistance in TypeEffectiveness.resistances(of: member.types) {
                resistCounts[resistance, default: 0] += 1
            }
        }
        let threshold = max(1, filledTeam.count / 2)
        return PokemonType.allCases.filter { (resistCounts[$0] ?? 0) >= threshold }
    }

    private func averageStats() -> PokemonStats {
        guard !filledTeam.isEmpty else {
            return PokemonStats(hp: 0, attack: 0, defense: 0, spAttack: 0, spDefense: 0, speed: 0)
        }
        let count = filledTeam.count
        return PokemonStats(
            hp: filledTeam.map(\.stats.hp).reduce(0, +) / count,
            attack: filledTeam.map(\.stats.attack).reduce(0, +) / count,
            defense: filledTeam.map(\.stats.defense).reduce(0, +) / count,
            spAttack: filledTeam.map(\.stats.spAttack).reduce(0, +) / count,
            spDefense: filledTeam.map(\.stats.spDefense).reduce(0, +) / count,
            speed: filledTeam.map(\.stats.speed).reduce(0, +) / count
        )
    }

    private func generateWarnings() -> [String] {
        var warnings: [String] = []

        // Uncovered offensive types
        let covered = Set(offensiveCoverage())
        let uncovered = PokemonType.allCases.filter { !covered.contains($0) }
        for type in uncovered {
            warnings.append("No tenés cobertura ofensiva contra tipo \(type.rawValue.capitalized).")
        }

        // Shared weaknesses (2+ members weak to same type)
        var weakCounts: [PokemonType: Int] = [:]
        for member in filledTeam {
            for weakness in TypeEffectiveness.weaknesses(of: member.types) {
                weakCounts[weakness, default: 0] += 1
            }
        }
        for type in PokemonType.allCases {
            let count = weakCounts[type] ?? 0
            if count >= 2 {
                warnings.append("\(count) Pokémon débiles a \(type.rawValue.capitalized).")
            }
        }

        // Duplicate types
        var typeCounts: [PokemonType: Int] = [:]
        for member in filledTeam {
            for t in member.types {
                typeCounts[t, default: 0] += 1
            }
        }
        for type in PokemonType.allCases {
            let count = typeCounts[type] ?? 0
            if count >= 3 {
                warnings.append("Tenés \(count) Pokémon de tipo \(type.rawValue.capitalized) — considerá diversificar.")
            }
        }

        // Low average stat total
        let avg = averageStats()
        if avg.total < 350 && filledTeam.count >= 3 {
            warnings.append("El promedio de stats totales es bajo (\(avg.total)). Considerá Pokémon más fuertes.")
        }

        return warnings
    }
}

// MARK: - Pokemon Picker Sheet

private struct PokemonPickerSheet: View {
    @Binding var team: [PokemonEntry?]
    let slotIndex: Int
    let gameVersion: GameVersion
    let gameId: String
    let onSelect: (PokemonEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var theme
    @State private var searchText = ""
    @State private var filterType: PokemonType?

    private var alreadyInTeam: Set<Int> {
        Set(team.compactMap { $0?.id })
    }

    private var filteredPokemon: [PokemonEntry] {
        PokemonLoader.entries(forGameId: gameId).filter { entry in
            let matchesSearch = searchText.isEmpty
                || entry.name.localizedCaseInsensitiveContains(searchText)
                || entry.dexString.contains(searchText)
            let matchesType = filterType == nil || entry.types.contains(filterType!)
            return matchesSearch && matchesType
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                typeFilterBar
                pokemonList
            }
            .background(Color.fireBg.ignoresSafeArea())
            .navigationTitle("Elegir Pokémon")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar por nombre o número...")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(theme.accent)
                }
            }
        }
    }

    private var typeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                filterChip(label: "Todos", type: nil)
                ForEach(PokemonType.allCases, id: \.self) { type in
                    filterChip(label: type.rawValue.capitalized, type: type)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func filterChip(label: String, type: PokemonType?) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { filterType = type }
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(filterType == type ? .white : (type?.color ?? theme.accent))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(filterType == type
                        ? (type?.color ?? theme.accent)
                        : (type?.color ?? theme.accent).opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }

    private var pokemonList: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(filteredPokemon) { entry in
                    let isAvailable = entry.isAvailable(in: gameVersion)
                    let isAlreadyPicked = alreadyInTeam.contains(entry.id)

                    Button {
                        guard isAvailable, !isAlreadyPicked else { return }
                        onSelect(entry)
                    } label: {
                        pickerRow(entry: entry, isAvailable: isAvailable, isAlreadyPicked: isAlreadyPicked)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isAvailable || isAlreadyPicked)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    private func pickerRow(entry: PokemonEntry, isAvailable: Bool, isAlreadyPicked: Bool) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: entry.spriteURL) { phase in
                switch phase {
                case .success(let image):
                    image.interpolation(.none).resizable().scaledToFit()
                        .frame(width: 40, height: 40)
                        .saturation(isAvailable && !isAlreadyPicked ? 1 : 0.3)
                case .failure:
                    Image(systemName: "questionmark")
                        .frame(width: 40, height: 40)
                        .foregroundColor(.fireTextSecondary)
                default:
                    ProgressView().controlSize(.small)
                        .frame(width: 40, height: 40)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(entry.dexString)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.fireTextSecondary)
                    Text(entry.name)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(isAvailable && !isAlreadyPicked ? .fireTextPrimary : .fireTextSecondary)
                }

                HStack(spacing: 4) {
                    ForEach(entry.types, id: \.self) { type in
                        TypeBadge(text: type.rawValue.capitalized, color: type.color)
                    }
                }
            }

            Spacer()

            if isAlreadyPicked {
                Text("En equipo")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.fireGray))
            } else if !isAvailable {
                Text(gameVersion == .fireRed ? "Solo LeafGreen" : "Solo FireRed")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.fireTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.fireGray))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .opacity(isAvailable && !isAlreadyPicked ? 1.0 : 0.5)
        .softCard(cornerRadius: 12, shadowRadius: 4)
    }
}

// MARK: - FlowLayout (wrapping horizontal layout for type badges)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 0, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(in maxWidth: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TeamBuilderView()
            .environmentObject(GameConfig())
    }
}
