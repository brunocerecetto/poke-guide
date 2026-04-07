//
//  EvolutionView.swift
//  PokemonGuide
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
            LazyVStack(spacing: 12) {
                ForEach(filteredChains) { chain in
                    chainCard(chain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color.fireBg.ignoresSafeArea())
        .navigationTitle("Evoluciones")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Buscar pokémon...")
    }

    // MARK: - Chain Card

    @ViewBuilder
    private func chainCard(_ chain: EvolutionChain) -> some View {
        VStack(spacing: 0) {
            if chain.isBranching {
                branchingChainContent(chain)
            } else {
                linearChainContent(chain)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .softCard(cornerRadius: 16, shadowRadius: 4)
    }

    // MARK: - Linear Chain

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

    // MARK: - Branching Chain (Eevee)

    private func branchingChainContent(_ chain: EvolutionChain) -> some View {
        VStack(spacing: 10) {
            // Base form centered
            if let base = chain.stages.first {
                spriteColumn(dex: base.id, name: base.name)
            }

            // Branches
            HStack(spacing: 4) {
                ForEach(chain.branches) { branch in
                    VStack(spacing: 4) {
                        methodBadge(branch.method)
                        Image(systemName: "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.fireTextSecondary.opacity(0.4))
                        spriteColumn(dex: branch.id, name: branch.name)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Sprite Column

    private func spriteColumn(dex: Int, name: String) -> some View {
        VStack(spacing: 4) {
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
                        .foregroundColor(.fireTextSecondary)
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
                .foregroundColor(.fireTextSecondary)

            Text(name)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.fireTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(minWidth: 68)
    }

    // MARK: - Arrow with Method

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

    // MARK: - Method Badge

    @ViewBuilder
    private func methodBadge(_ method: EvolutionMethod?) -> some View {
        if let method {
            HStack(spacing: 3) {
                Image(systemName: method.icon)
                    .font(.system(size: 8))
                Text(method.label)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
            }
            .foregroundColor(methodColor(method))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(methodColor(method).opacity(0.10))
            )
        }
    }

    // MARK: - Helpers

    private func spriteURL(for dex: Int) -> URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(dex).png")
    }

    private func methodColor(_ method: EvolutionMethod) -> Color {
        switch method {
        case .level:  return .fireBlue
        case .stone:  return .fireGreen
        case .trade:  return .fireOrange
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EvolutionView()
    }
}
