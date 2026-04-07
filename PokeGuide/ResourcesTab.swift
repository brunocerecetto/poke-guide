//
//  ResourcesTab.swift
//  PokeGuide
//
//  Reference material: Tabla de Tipos, HMs & TMs, Tips, Evoluciones.
//

import SwiftUI

struct ResourcesTab: View {
    @Environment(\.themeColors) private var theme
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            PageLayout(background: .clear) {
                VStack(spacing: KASpacing.sm) {
                    ForEach(Array(items.enumerated()), id: \.element.title) { index, item in
                        NavigationLink {
                            item.destination.view
                        } label: {
                            resourceCard(item: item)
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(KAAnimation.appearSpring.delay(0.05 + Double(index) * KAAnimation.staggerDelay), value: appeared)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, KASpacing.sm + KASpacing.xs)
            }
            .background(PixelBackground())
            .navigationTitle("Recursos")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(KAAnimation.appearSpring) { appeared = true }
            }
        }
    }

    private func resourceCard(item: ResourceItem) -> some View {
        HStack(spacing: KASpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.color.opacity(0.10))
                    .frame(width: 38, height: 38)

                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(item.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(KATypography.titleSm)
                    .foregroundColor(.onSurface)
                Text(item.subtitle)
                    .font(KATypography.labelSm)
                    .foregroundColor(.onSurfaceVariant)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.outlineVariant)
        }
        .padding(.horizontal, KASpacing.md)
        .padding(.vertical, KASpacing.sm + KASpacing.xs)
        .softCard(cornerRadius: KARadius.lg, tint: item.color)
    }

    // MARK: - Data

    private enum ResourceDestination {
        case typeChart, hmtm, tips, evolution, kantoMap

        @ViewBuilder var view: some View {
            switch self {
            case .typeChart:  TypeChartView()
            case .hmtm:       HMTMView()
            case .tips:       TipsView()
            case .evolution:  EvolutionView()
            case .kantoMap:   KantoMapView()
            }
        }
    }

    private struct ResourceItem: Identifiable {
        var id: String { title }
        let icon: String
        let title: String
        let subtitle: String
        let color: Color
        let destination: ResourceDestination
    }

    private var items: [ResourceItem] {
        [
            ResourceItem(icon: "square.grid.3x3.fill", title: "Tabla de Tipos", subtitle: "Efectividad de ataques", color: theme.accent, destination: .typeChart),
            ResourceItem(icon: "arrow.triangle.swap", title: "HMs & TMs", subtitle: "Reparto y compras", color: .teal, destination: .hmtm),
            ResourceItem(icon: "lightbulb.fill", title: "Tips & Tricks", subtitle: "Reglas de evolución y más", color: .kaYellow, destination: .tips),
            ResourceItem(icon: "arrow.triangle.branch", title: "Evoluciones", subtitle: "Cadenas y métodos", color: .success, destination: .evolution),
            ResourceItem(icon: "map.fill", title: "Mapa de Kanto", subtitle: "Ciudades y rutas", color: .blue, destination: .kantoMap),
        ]
    }
}
