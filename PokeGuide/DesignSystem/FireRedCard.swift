//
//  FireRedCard.swift
//  PokeGuide
//
//  Simple padded card wrapper.
//

import SwiftUI

struct FireRedCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding()
            .softCard(cornerRadius: KARadius.md)
    }
}
