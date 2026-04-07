//
//  PokedexTab.swift
//  PokeGuide
//
//  Thin wrapper — NavigationStack for the Pokédex.
//

import SwiftUI

struct PokedexTab: View {
    var body: some View {
        NavigationStack {
            PokedexView()
        }
    }
}
