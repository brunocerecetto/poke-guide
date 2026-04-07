//
//  PokemonPickerSheet.swift
//  PokeGuide
//
//  Shared Pokémon picker modal + FlowLayout.
//

import SwiftUI

struct PokemonPickerSheet: View {
    let alreadyPickedDexNumbers: Set<Int>
    let gameVersion: GameVersion
    let gameId: String
    let onSelect: (PokemonEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var theme
    @State private var searchText = ""
    @State private var filterType: PokemonType?

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
            .background(Color.surface.ignoresSafeArea())
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
            .padding(.vertical, KASpacing.sm)
        }
    }

    private func filterChip(label: String, type: PokemonType?) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { filterType = type }
        } label: {
            Text(label)
                .font(KATypography.bodySmall)
                .foregroundColor(filterType == type ? .onPrimary : (type?.color ?? theme.accent))
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
                    let isAlreadyPicked = alreadyPickedDexNumbers.contains(entry.id)

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
        HStack(spacing: KASpacing.sm + KASpacing.xs) {
            AsyncImage(url: entry.spriteURL) { phase in
                switch phase {
                case .success(let image):
                    image.interpolation(.none).resizable().scaledToFit()
                        .frame(width: 40, height: 40)
                        .saturation(isAvailable && !isAlreadyPicked ? 1 : 0.3)
                case .failure:
                    Image(systemName: "questionmark")
                        .frame(width: 40, height: 40)
                        .foregroundColor(.onSurfaceVariant)
                default:
                    ProgressView().controlSize(.small)
                        .frame(width: 40, height: 40)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: KASpacing.xs) {
                    Text(entry.dexString)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant)
                    Text(entry.name)
                        .font(KATypography.titleSm)
                        .foregroundColor(isAvailable && !isAlreadyPicked ? .onSurface : .onSurfaceVariant)
                }

                HStack(spacing: KASpacing.xs) {
                    ForEach(entry.types, id: \.self) { type in
                        TypeBadge(text: type.rawValue.capitalized, color: type.color)
                    }
                }
            }

            Spacer()

            if isAlreadyPicked {
                Text("En equipo")
                    .font(KATypography.labelXs)
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.horizontal, KASpacing.sm)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.surfaceContainerHighest))
            } else if !isAvailable {
                Text(gameVersion == .fireRed ? "Solo LeafGreen" : "Solo FireRed")
                    .font(KATypography.labelXs)
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.horizontal, KASpacing.sm)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.surfaceContainerHighest))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, KASpacing.sm + KASpacing.xs)
        .opacity(isAvailable && !isAlreadyPicked ? 1.0 : 0.5)
        .softCard(cornerRadius: KARadius.lg)
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(in: proposal.width ?? 0, subviews: subviews).size
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
