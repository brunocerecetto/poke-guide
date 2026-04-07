//
//  MainTabView.swift
//  PokeGuide
//
//  Root tab bar — 4 tabs: Guía, Pokédex, Equipo, Recursos.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.themeColors) private var theme
    @State private var selectedTab: Tab = .guide

    enum Tab: Int {
        case guide, pokedex, team, resources
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            GuideTab()
                .tabItem { Label("Guía", systemImage: "map.fill") }
                .tag(Tab.guide)

            PokedexTab()
                .tabItem { Label("Pokédex", systemImage: "book.closed.fill") }
                .tag(Tab.pokedex)

            TeamTab()
                .tabItem { Label("Equipo", systemImage: "person.3.fill") }
                .tag(Tab.team)

            ResourcesTab()
                .tabItem { Label("Recursos", systemImage: "books.vertical.fill") }
                .tag(Tab.resources)
        }
        .tint(theme.accent)
    }
}
