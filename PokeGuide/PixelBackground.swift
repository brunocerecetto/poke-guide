//
//  PixelBackground.swift
//  pokemon guide
//
//  Fondo adaptivo — gradiente cálido (light) / oscuro (dark) con patrón sutil de Pokéball.
//

import SwiftUI

struct PixelBackground: View {
    @Environment(\.themeColors) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let isDark = colorScheme == .dark

        ZStack {
            // Base gradient (adaptive)
            LinearGradient(
                colors: isDark
                    ? [
                        Color(red: 0.10, green: 0.10, blue: 0.12),
                        Color(red: 0.09, green: 0.09, blue: 0.11),
                        Color(red: 0.10, green: 0.10, blue: 0.12),
                    ]
                    : [
                        Color(red: 0.97, green: 0.95, blue: 0.92),
                        Color(red: 0.95, green: 0.93, blue: 0.90),
                        Color(red: 0.96, green: 0.94, blue: 0.91),
                    ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Subtle warm accent at top
            EllipticalGradient(
                colors: [
                    theme.accent.opacity(isDark ? 0.08 : 0.06),
                    theme.secondary.opacity(isDark ? 0.04 : 0.03),
                    Color.clear
                ],
                center: .top,
                startRadiusFraction: 0,
                endRadiusFraction: 0.7
            )

            // Pokéball watermark pattern
            let watermarkOpacity: Double = isDark ? 0.4 : 1.0

            GeometryReader { geo in
                Canvas { context, size in
                    let spacing: CGFloat = 80
                    let dotSize: CGFloat = 3

                    for row in stride(from: CGFloat(-20), to: size.height + 40, by: spacing) {
                        let offset: CGFloat = (Int(row / spacing) % 2 == 0) ? 0 : spacing / 2
                        for col in stride(from: CGFloat(-20) + offset, to: size.width + 40, by: spacing) {
                            let cx = col
                            let cy = row
                            let r: CGFloat = 8
                            let markColor: Color = isDark ? .white : .black

                            // Top half (accent tinted)
                            var topPath = Path()
                            topPath.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            topPath.closeSubpath()
                            context.fill(topPath, with: .color(theme.accent.opacity(0.04 * watermarkOpacity)))

                            // Bottom half
                            var bottomPath = Path()
                            bottomPath.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                            bottomPath.closeSubpath()
                            context.fill(bottomPath, with: .color(markColor.opacity(0.02 * watermarkOpacity)))

                            // Center line
                            let linePath = Path(CGRect(x: cx - r, y: cy - 0.5, width: r * 2, height: 1))
                            context.fill(linePath, with: .color(markColor.opacity(0.03 * watermarkOpacity)))

                            // Center dot
                            let dotRect = CGRect(x: cx - dotSize/2, y: cy - dotSize/2, width: dotSize, height: dotSize)
                            context.fill(Path(ellipseIn: dotRect), with: .color(markColor.opacity(0.04 * watermarkOpacity)))

                            // Circle outline
                            context.stroke(
                                Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                                with: .color(markColor.opacity(0.03 * watermarkOpacity)),
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
