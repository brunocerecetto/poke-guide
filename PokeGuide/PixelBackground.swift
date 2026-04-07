//
//  PixelBackground.swift
//  poke guide
//
//  Fondo adaptivo — superficie neutral con patrón sutil de Pokéball.
//

import SwiftUI

struct PixelBackground: View {
    private static let patternSpacing: CGFloat = 80
    private static let patternDotSize: CGFloat = 3

    @Environment(\.themeColors) private var theme

    var body: some View {
        ZStack {
            // Base surface
            Color.surface

            // Subtle accent glow at top
            EllipticalGradient(
                colors: [
                    theme.accent.opacity(0.05),
                    theme.secondary.opacity(0.03),
                    Color.clear
                ],
                center: .top,
                startRadiusFraction: 0,
                endRadiusFraction: 0.7
            )

            // Pokéball watermark pattern
            GeometryReader { geo in
                Canvas { context, size in
                    let spacing: CGFloat = Self.patternSpacing
                    let dotSize: CGFloat = Self.patternDotSize

                    for row in stride(from: CGFloat(-20), to: size.height + 40, by: spacing) {
                        let offset: CGFloat = (Int(row / spacing) % 2 == 0) ? 0 : spacing / 2
                        for col in stride(from: CGFloat(-20) + offset, to: size.width + 40, by: spacing) {
                            let cx = col
                            let cy = row
                            let r: CGFloat = 8

                            // Top half (accent tinted)
                            var topPath = Path()
                            topPath.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            topPath.closeSubpath()
                            context.fill(topPath, with: .color(theme.accent.opacity(0.03)))

                            // Bottom half
                            var bottomPath = Path()
                            bottomPath.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                            bottomPath.closeSubpath()
                            context.fill(bottomPath, with: .color(Color.outlineVariant.opacity(0.04)))

                            // Center line
                            let linePath = Path(CGRect(x: cx - r, y: cy - 0.5, width: r * 2, height: 1))
                            context.fill(linePath, with: .color(Color.outlineVariant.opacity(0.05)))

                            // Center dot
                            let dotRect = CGRect(x: cx - dotSize/2, y: cy - dotSize/2, width: dotSize, height: dotSize)
                            context.fill(Path(ellipseIn: dotRect), with: .color(Color.outlineVariant.opacity(0.06)))

                            // Circle outline
                            context.stroke(
                                Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                                with: .color(Color.outlineVariant.opacity(0.04)),
                                lineWidth: 0.5
                            )
                        }
                    }
                }
            }
            .drawingGroup()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    PixelBackground()
}
