//
//  TypeChartView.swift
//  PokemonGuide
//
//  Tabla de efectividad de tipos — Gen 3 (FireRed/LeafGreen).
//

import SwiftUI

// MARK: - Type Effectiveness Data (Gen 3 / FRLG)

/// Multiplier when `attacker` hits `defender`.
/// Only non-1.0 matchups are stored; missing = 1.0 (neutral).
private let typeEffectiveness: [PokemonType: [PokemonType: Double]] = {
    let s: Double = 2.0   // super effective
    let n: Double = 0.5   // not very effective
    let z: Double = 0.0   // immune

    return [
        .normal: [
            .rock: n, .ghost: z, .steel: n
        ],
        .fire: [
            .fire: n, .water: n, .grass: s, .ice: s, .bug: s, .rock: n, .dragon: n, .steel: s
        ],
        .water: [
            .fire: s, .water: n, .grass: n, .ground: s, .rock: s, .dragon: n
        ],
        .grass: [
            .fire: n, .water: s, .grass: n, .poison: n, .ground: s, .flying: n, .bug: n,
            .rock: s, .dragon: n, .steel: n
        ],
        .electric: [
            .water: s, .grass: n, .electric: n, .ground: z, .flying: s, .dragon: n
        ],
        .ice: [
            .fire: n, .water: n, .grass: s, .ice: n, .ground: s, .flying: s, .dragon: s, .steel: n
        ],
        .fighting: [
            .normal: s, .ice: s, .poison: n, .flying: n, .psychic: n, .bug: n,
            .rock: s, .ghost: z, .steel: s
        ],
        .poison: [
            .grass: s, .poison: n, .ground: n, .rock: n, .ghost: n, .steel: z
        ],
        .ground: [
            .fire: s, .electric: s, .grass: n, .poison: s, .flying: z, .bug: n, .rock: s, .steel: s
        ],
        .flying: [
            .grass: s, .electric: n, .fighting: s, .bug: s, .rock: n, .steel: n
        ],
        .psychic: [
            .fighting: s, .poison: s, .psychic: n, .steel: n
        ],
        .bug: [
            .fire: n, .grass: s, .fighting: n, .poison: n, .flying: n, .psychic: s, .ghost: n, .steel: n
        ],
        .rock: [
            .fire: s, .ice: s, .fighting: n, .ground: n, .flying: s, .bug: s, .steel: n
        ],
        .ghost: [
            .normal: z, .psychic: s, .ghost: s, .steel: n
        ],
        .dragon: [
            .dragon: s, .steel: n
        ],
        .steel: [
            .fire: n, .water: n, .electric: n, .ice: s, .rock: s, .steel: n
        ],
    ]
}()

// MARK: - Spanish Names

extension PokemonType {
    var spanishName: String {
        switch self {
        case .normal:   return "Normal"
        case .fire:     return "Fuego"
        case .water:    return "Agua"
        case .grass:    return "Planta"
        case .electric: return "Eléctrico"
        case .ice:      return "Hielo"
        case .fighting: return "Lucha"
        case .poison:   return "Veneno"
        case .ground:   return "Tierra"
        case .flying:   return "Volador"
        case .psychic:  return "Psíquico"
        case .bug:      return "Bicho"
        case .rock:     return "Roca"
        case .ghost:    return "Fantasma"
        case .dragon:   return "Dragón"
        case .steel:    return "Acero"
        }
    }

    /// Short 3-letter abbreviation for the chart headers.
    var shortLabel: String {
        switch self {
        case .normal:   return "NOR"
        case .fire:     return "FUE"
        case .water:    return "AGU"
        case .grass:    return "PLA"
        case .electric: return "ELE"
        case .ice:      return "HIE"
        case .fighting: return "LUC"
        case .poison:   return "VEN"
        case .ground:   return "TIE"
        case .flying:   return "VOL"
        case .psychic:  return "PSI"
        case .bug:      return "BIC"
        case .rock:     return "ROC"
        case .ghost:    return "FAN"
        case .dragon:   return "DRA"
        case .steel:    return "ACE"
        }
    }
}

// MARK: - Effectiveness Enum

private enum Effectiveness {
    case superEffective  // 2x
    case notVeryEffective // 0.5x
    case immune          // 0x
    case neutral         // 1x

    init(multiplier: Double) {
        switch multiplier {
        case 2.0:  self = .superEffective
        case 0.5:  self = .notVeryEffective
        case 0.0:  self = .immune
        default:   self = .neutral
        }
    }

    var label: String {
        switch self {
        case .superEffective:   return "Super efectivo (2x)"
        case .notVeryEffective: return "Poco efectivo (0.5x)"
        case .immune:           return "Inmune (0x)"
        case .neutral:          return "Normal (1x)"
        }
    }

    var cellText: String {
        switch self {
        case .superEffective:   return "2"
        case .notVeryEffective: return "½"
        case .immune:           return "0"
        case .neutral:          return ""
        }
    }

    var cellColor: Color {
        switch self {
        case .superEffective:   return Color(red: 0.25, green: 0.72, blue: 0.35)
        case .notVeryEffective: return Color(red: 0.88, green: 0.30, blue: 0.25)
        case .immune:           return Color(red: 0.15, green: 0.15, blue: 0.18)
        case .neutral:          return Color.clear
        }
    }

    var textColor: Color {
        switch self {
        case .neutral: return .clear
        default:       return .white
        }
    }
}

// MARK: - Helper

private func effectiveness(attacker: PokemonType, defender: PokemonType) -> Effectiveness {
    let multiplier = typeEffectiveness[attacker]?[defender] ?? 1.0
    return Effectiveness(multiplier: multiplier)
}

// MARK: - TypeChartView

struct TypeChartView: View {
    @Environment(\.themeColors) private var theme

    private let allTypes = PokemonType.allCases
    private let cellSize: CGFloat = 36
    private let headerWidth: CGFloat = 44

    @State private var selectedCell: (attacker: PokemonType, defender: PokemonType)?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                legend
                    .padding(.horizontal)

                chartContainer
                    .padding(.horizontal, 4)

                if let cell = selectedCell {
                    cellDetail(attacker: cell.attacker, defender: cell.defender)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer(minLength: 30)
            }
            .padding(.top, 8)
        }
        .background(Color.fireBg.ignoresSafeArea())
        .navigationTitle("Tabla de Tipos")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Legend

    private var legend: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(theme.accent)
                Text("Efectividad de tipos")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.fireTextPrimary)
                Spacer()
            }

            HStack(spacing: 12) {
                legendItem(color: Effectiveness.superEffective.cellColor, label: "2x")
                legendItem(color: Effectiveness.notVeryEffective.cellColor, label: "½x")
                legendItem(color: Effectiveness.immune.cellColor, label: "0x")
                legendItem(color: Color.fireBg, label: "1x", border: true)
                Spacer()
            }

            Text("Fila = tipo atacante  ·  Columna = tipo defensor")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.fireTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .softCard(cornerRadius: 16, tint: theme.accent, shadowRadius: 6)
    }

    private func legendItem(color: Color, label: String, border: Bool = false) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 18, height: 18)
                .overlay(
                    Group {
                        if border {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        }
                    }
                )
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.fireTextSecondary)
        }
    }

    // MARK: - Chart

    private var chartContainer: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                // Column headers row
                HStack(spacing: 0) {
                    // Top-left corner: empty cell
                    Color.clear
                        .frame(width: headerWidth, height: cellSize)

                    ForEach(allTypes, id: \.self) { defType in
                        columnHeader(defType)
                    }
                }

                // Data rows
                ForEach(allTypes, id: \.self) { atkType in
                    HStack(spacing: 0) {
                        rowHeader(atkType)

                        ForEach(allTypes, id: \.self) { defType in
                            cell(attacker: atkType, defender: defType)
                        }
                    }
                }
            }
            .padding(6)
            .softCard(cornerRadius: 14, shadowOpacity: 0.06, shadowRadius: 8)
        }
    }

    private func columnHeader(_ type: PokemonType) -> some View {
        VStack(spacing: 2) {
            Image(systemName: type.icon)
                .font(.system(size: 9))
                .foregroundColor(type.color)
            Text(type.shortLabel)
                .font(.system(size: 8, weight: .heavy, design: .rounded))
                .foregroundColor(type.color)
        }
        .frame(width: cellSize, height: cellSize)
        .background(type.color.opacity(0.08))
        .cornerRadius(4)
    }

    private func rowHeader(_ type: PokemonType) -> some View {
        HStack(spacing: 3) {
            Image(systemName: type.icon)
                .font(.system(size: 9))
                .foregroundColor(type.color)
            Text(type.shortLabel)
                .font(.system(size: 8, weight: .heavy, design: .rounded))
                .foregroundColor(type.color)
        }
        .frame(width: headerWidth, height: cellSize)
        .background(type.color.opacity(0.08))
        .cornerRadius(4)
    }

    private func cell(attacker: PokemonType, defender: PokemonType) -> some View {
        let eff = effectiveness(attacker: attacker, defender: defender)
        let isSelected = selectedCell?.attacker == attacker && selectedCell?.defender == defender

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                if isSelected {
                    selectedCell = nil
                } else {
                    selectedCell = (attacker, defender)
                }
            }
        } label: {
            Text(eff.cellText)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(eff.textColor)
                .frame(width: cellSize, height: cellSize)
                .background(eff.cellColor.opacity(eff == .neutral ? 0 : 0.85))
                .background(Color.black.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(isSelected ? theme.accent : Color.black.opacity(0.06), lineWidth: isSelected ? 2 : 0.5)
                )
                .cornerRadius(3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Cell Detail (Tooltip)

    private func cellDetail(attacker: PokemonType, defender: PokemonType) -> some View {
        let eff = effectiveness(attacker: attacker, defender: defender)

        return HStack(spacing: 12) {
            TypeBadge(text: attacker.spanishName, color: attacker.color)

            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.fireTextSecondary)

            TypeBadge(text: defender.spanishName, color: defender.color)

            Spacer()

            Text(eff.label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(eff == .neutral ? .fireTextSecondary : eff.cellColor)
        }
        .padding(14)
        .softCard(cornerRadius: 14, tint: attacker.color, shadowRadius: 8)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TypeChartView()
    }
}
