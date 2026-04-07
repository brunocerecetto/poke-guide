//
//  KASectionHeader.swift
//  PokeGuide
//
//  Themed section header with icon.
//

import SwiftUI

struct KASectionHeader: View {
    let title: String
    let icon: String
    @Environment(\.themeColors) private var theme

    var body: some View {
        HStack(spacing: KASpacing.sm) {
            Image(systemName: icon)
                .foregroundColor(theme.accent)
            Text(title)
                .font(KATypography.titleSm)
                .foregroundColor(theme.accent)
        }
        .textCase(nil)
    }
}

typealias FireRedSectionHeader = KASectionHeader
