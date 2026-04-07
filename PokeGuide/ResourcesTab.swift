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
                            item.destination
                        } label: {
                            resourceCard(item: item)
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05 + Double(index) * 0.04), value: appeared)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, KASpacing.sm + KASpacing.xs)
            }
            .background(PixelBackground())
            .navigationTitle("Recursos")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appeared = true }
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

    private struct ResourceItem: Identifiable {
        var id: String { title }
        let icon: String
        let title: String
        let subtitle: String
        let color: Color
        let destination: AnyView
    }

    private var items: [ResourceItem] {
        [
            ResourceItem(icon: "square.grid.3x3.fill", title: "Tabla de Tipos", subtitle: "Efectividad de ataques", color: .kaPrimary, destination: AnyView(TypeChartView())),
            ResourceItem(icon: "arrow.triangle.swap", title: "HMs & TMs", subtitle: "Reparto y compras", color: .teal, destination: AnyView(HMTMView())),
            ResourceItem(icon: "lightbulb.fill", title: "Tips & Tricks", subtitle: "Reglas de evolución y más", color: .kaYellow, destination: AnyView(TipsView())),
            ResourceItem(icon: "arrow.triangle.branch", title: "Evoluciones", subtitle: "Cadenas y métodos", color: .success, destination: AnyView(EvolutionView())),
            ResourceItem(icon: "map.fill", title: "Mapa de Kanto", subtitle: "Ciudades y rutas", color: .blue, destination: AnyView(KantoMapView())),
        ]
    }
}
