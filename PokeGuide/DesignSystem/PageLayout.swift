//
//  PageLayout.swift
//  PokeGuide
//
//  Base scroll layout that wraps page content and appends the fan disclaimer.
//  Optionally applies navigation title with standard display settings.
//

import SwiftUI

struct PageLayout<Content: View>: View {
    let title: String?
    let showsIndicators: Bool
    let background: Color
    @ViewBuilder let content: Content

    init(
        _ title: String? = nil,
        showsIndicators: Bool = false,
        background: Color = .surface,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.showsIndicators = showsIndicators
        self.background = background
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: showsIndicators) {
                VStack(spacing: 0) {
                    content

                    Spacer(minLength: 0)

                    FanDisclaimer()
                }
                .frame(minHeight: geo.size.height)
            }
        }
        .background(background.ignoresSafeArea())
        .modifier(NavigationTitleModifier(title: title))
    }
}

private struct NavigationTitleModifier: ViewModifier {
    let title: String?

    func body(content: Content) -> some View {
        if let title {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.automatic, for: .navigationBar)
        } else {
            content
        }
    }
}
