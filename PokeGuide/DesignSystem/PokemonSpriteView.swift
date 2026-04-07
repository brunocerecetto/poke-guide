//
//  PokemonSpriteView.swift
//  PokeGuide
//
//  Reusable AsyncImage wrapper for Pokémon sprites with pixel-art interpolation.
//

import SwiftUI

struct PokemonSpriteView: View {
    let url: URL?
    var size: CGFloat = 40
    var fallbackEmoji: String? = nil
    var saturation: Double = 1.0

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .saturation(saturation)
            case .failure:
                if let emoji = fallbackEmoji {
                    Text(emoji)
                        .font(.system(size: size * 0.45))
                } else {
                    Image(systemName: "questionmark")
                        .font(.system(size: size * 0.35))
                        .foregroundColor(.onSurfaceVariant)
                }
            default:
                ProgressView()
                    .frame(width: size, height: size)
            }
        }
    }
}
