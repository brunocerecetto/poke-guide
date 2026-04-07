//
//  EvolutionView.swift
//  PokeGuide
//
//  Cadenas evolutivas de Kanto — vista visual con sprites y flechas.
//

import SwiftUI

struct EvolutionView: View {
    @Environment(\.themeColors) private var theme
    @State private var searchText = ""

    private var filteredChains: [EvolutionChain] {
        guard !searchText.isEmpty else { return EvolutionData.chains }
        let query = searchText.lowercased()
        return EvolutionData.chains.filter { chain in
            let allStages = chain.stages + chain.branches
            return allStages.contains(where: {
                $0.name.lowercased().contains(query) || "\($0.id)".contains(query)
            })
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: KASpacing.sm + KASpacing.xs) {
                ForEach(filteredChains) { chain in
                    chainCard(chain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle("Evoluciones")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Buscar pokémon...")
    }

    @ViewBuilder
    private func chainCard(_ chain: EvolutionChain) -> some View {
        VStack(spacing: 0) {
            if chain.isBranching {
                branchingChainContent(chain)
            } else {
                linearChainContent(chain)
            }
        }
        .padding(.vertical, KASpacing.md)
        .padding(.horizontal, KASpacing.sm)
        .softCard(cornerRadius: KARadius.lg)
    }

    private func linearChainContent(_ chain: EvolutionChain) -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            ForEach(Array(chain.stages.enumerated()), id: \.element.id) { index, stage in
                if index > 0 {
                    arrowView(method: stage.method)
                }
                spriteColumn(dex: stage.id, name: stage.name)
            }
            Spacer(minLength: 0)
        }
    }

    private func branchingChainContent(_ chain: EvolutionChain) -> some View {
        VStack(spacing: 10) {
            if let base = chain.stages.first {
                spriteColumn(dex: base.id, name: base.name)
            }

            HStack(spacing: KASpacing.xs) {
                ForEach(chain.branches) { branch in
                    VStack(spacing: KASpacing.xs) {
                        methodBadge(branch.method)
                        Image(systemName: "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.outlineVariant)
                        spriteColumn(dex: branch.id, name: branch.name)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func spriteColumn(dex: Int, name: String) -> some View {
        VStack(spacing: KASpacing.xs) {
            AsyncImage(url: spriteURL(for: dex)) { phase in
                switch phase {
                case .success(let image):
                    image.interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                case .failure:
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.onSurfaceVariant)
                        .frame(width: 56, height: 56)
                case .empty:
                    ProgressView()
                        .frame(width: 56, height: 56)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 56, height: 56)

            Text("#\(String(format: "%03d", dex))")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurfaceVariant)

            Text(name)
                .font(KATypography.labelSm)
                .foregroundColor(.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(minWidth: 68)
    }

    private func arrowView(method: EvolutionMethod?) -> some View {
        VStack(spacing: 2) {
            if let method {
                methodBadge(method)
            }
            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(theme.accent.opacity(0.5))
        }
        .frame(minWidth: 54)
        .padding(.horizontal, 2)
    }

    @ViewBuilder
    private func methodBadge(_ method: EvolutionMethod?) -> some View {
        if let method {
            HStack(spacing: 3) {
                Image(systemName: method.icon)
                    .font(.system(size: 8))
                Text(method.label)
                    .font(KATypography.labelXs)
            }
            .foregroundColor(methodColor(method))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(methodColor(method).opacity(0.10))
            )
        }
    }

    private func spriteURL(for dex: Int) -> URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(dex).png")
    }

    private func methodColor(_ method: EvolutionMethod) -> Color {
        switch method {
        case .level:  return .kaSecondaryContainer
        case .stone:  return .success
        case .trade:  return .primaryContainer
        }
    }
}

#Preview {
    NavigationStack {
        EvolutionView()
    }
}
