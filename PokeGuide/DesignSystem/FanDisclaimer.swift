//
//  FanDisclaimer.swift
//  PokeGuide
//
//  "Created by fans for fans" footer disclaimer.
//

import SwiftUI

struct FanDisclaimer: View {
    var body: some View {
        VStack(spacing: 3) {
            Text("Created by fans for fans")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.onSurfaceVariant.opacity(0.4))

            Text("This unofficial app is not supported, approved or affiliated by Nintendo, Game Freak or The Pokémon Company.")
                .font(.system(size: 9, weight: .regular, design: .rounded))
                .foregroundColor(.onSurfaceVariant.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, KASpacing.xl)
        .padding(.top, KASpacing.md)
        .padding(.bottom, KASpacing.sm)
    }
}
