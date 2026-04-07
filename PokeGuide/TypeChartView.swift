//
//  TypeChartView.swift
//  PokeGuide
//
//  Tabla de efectividad de tipos — Gen 6+ (18 tipos).
//

import SwiftUI

// MARK: - Type Effectiveness Data (Gen 6+)

private let typeEffectiveness: [PokemonType: [PokemonType: Double]] = {
    let s: Double = 2.0
    let n: Double = 0.5
    let z: Double = 0.0

    return [
        .normal: [.rock: n, .ghost: z, .steel: n],
        .fire: [.fire: n, .water: n, .grass: s, .ice: s, .bug: s, .rock: n, .dragon: n, .steel: s],
        .water: [.fire: s, .water: n, .grass: n, .ground: s, .rock: s, .dragon: n],
        .grass: [.fire: n, .water: s, .grass: n, .poison: n, .ground: s, .flying: n, .bug: n, .rock: s, .dragon: n, .steel: n],
        .electric: [.water: s, .grass: n, .electric: n, .ground: z, .flying: s, .dragon: n],
        .ice: [.fire: n, .water: n, .grass: s, .ice: n, .ground: s, .flying: s, .dragon: s, .steel: n],
        .fighting: [.normal: s, .ice: s, .poison: n, .flying: n, .psychic: n, .bug: n, .rock: s, .ghost: z, .dark: s, .steel: s, .fairy: n],
        .poison: [.grass: s, .poison: n, .ground: n, .rock: n, .ghost: n, .steel: z, .fairy: s],
        .ground: [.fire: s, .electric: s, .grass: n, .poison: s, .flying: z, .bug: n, .rock: s, .steel: s],
        .flying: [.grass: s, .electric: n, .fighting: s, .bug: s, .rock: n, .steel: n],
        .psychic: [.fighting: s, .poison: s, .psychic: n, .dark: z, .steel: n],
        .bug: [.fire: n, .grass: s, .fighting: n, .poison: n, .flying: n, .psychic: s, .ghost: n, .dark: s, .steel: n, .fairy: n],
        .rock: [.fire: s, .ice: s, .fighting: n, .ground: n, .flying: s, .bug: s, .steel: n],
        .ghost: [.normal: z, .psychic: s, .ghost: s, .dark: n],
        .dragon: [.dragon: s, .steel: n, .fairy: z],
        .dark: [.fighting: n, .psychic: s, .ghost: s, .dark: n, .fairy: n],
        .steel: [.fire: n, .water: n, .electric: n, .ice: s, .rock: s, .steel: n, .fairy: s],
        .fairy: [.fire: n, .fighting: s, .poison: n, .dragon: s, .dark: s, .steel: n],
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
        case .dark:     return "Siniestro"
        case .steel:    return "Acero"
        case .fairy:    return "Hada"
        }
    }

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
        case .dark:     return "SIN"
        case .steel:    return "ACE"
        case .fairy:    return "HAD"
        }
    }
}

// MARK: - Effectiveness Enum

private enum Effectiveness {
    case superEffective
    case notVeryEffective
    case immune
    case neutral

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
        case .immune:           return .inverseSurface
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
        PageLayout("Tabla de Tipos") {
            VStack(spacing: KASpacing.md) {
                legend
                    .padding(.horizontal)

                chartContainer
                    .padding(.horizontal, KASpacing.xs)

                if let cell = selectedCell {
                    cellDetail(attacker: cell.attacker, defender: cell.defender)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.top, KASpacing.sm)
        }
    }

    private var legend: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(theme.accent)
                Text("Efectividad de tipos")
                    .font(KATypography.titleSm)
                    .foregroundColor(.onSurface)
                Spacer()
            }

            HStack(spacing: KASpacing.sm + KASpacing.xs) {
                legendItem(color: Effectiveness.superEffective.cellColor, label: "2x")
                legendItem(color: Effectiveness.notVeryEffective.cellColor, label: "½x")
                legendItem(color: Effectiveness.immune.cellColor, label: "0x")
                legendItem(color: Color.surface, label: "1x", border: true)
                Spacer()
            }

            Text("Fila = tipo atacante  ·  Columna = tipo defensor")
                .font(KATypography.labelSm)
                .foregroundColor(.onSurfaceVariant)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg, tint: theme.accent)
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
                                .stroke(Color.outlineVariant.opacity(0.3), lineWidth: 1)
                        }
                    }
                )
            Text(label)
                .font(KATypography.labelSm)
                .foregroundColor(.onSurfaceVariant)
        }
    }

    private var chartContainer: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Color.clear
                        .frame(width: headerWidth, height: cellSize)

                    ForEach(allTypes, id: \.self) { defType in
                        columnHeader(defType)
                    }
                }

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
            .softCard(cornerRadius: KARadius.md)
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
                .background(Color.onSurface.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(isSelected ? theme.accent : Color.outlineVariant.opacity(0.12), lineWidth: isSelected ? 2 : 0.5)
                )
                .cornerRadius(3)
        }
        .buttonStyle(.plain)
    }

    private func cellDetail(attacker: PokemonType, defender: PokemonType) -> some View {
        let eff = effectiveness(attacker: attacker, defender: defender)

        return HStack(spacing: KASpacing.sm + KASpacing.xs) {
            TypeBadge(text: attacker.spanishName, color: attacker.color)

            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.onSurfaceVariant)

            TypeBadge(text: defender.spanishName, color: defender.color)

            Spacer()

            Text(eff.label)
                .font(KATypography.labelSm)
                .foregroundColor(eff == .neutral ? .onSurfaceVariant : eff.cellColor)
        }
        .padding(KASpacing.md)
        .softCard(cornerRadius: KARadius.lg, tint: attacker.color)
    }
}

#Preview {
    NavigationStack {
        TypeChartView()
    }
}
