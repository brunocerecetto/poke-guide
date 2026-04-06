//
//  PixelBackground.swift
//  pokemon guide
//
//  Fondo light mode — gradiente cálido con patrón sutil de Pokéball.
//

import SwiftUI

struct PixelBackground: View {
    var body: some View {
        ZStack {
            // Base warm gradient
            LinearGradient(
                colors: [
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
                    Color.fireRed.opacity(0.06),
                    Color.fireOrange.opacity(0.03),
                    Color.clear
                ],
                center: .top,
                startRadiusFraction: 0,
                endRadiusFraction: 0.7
            )

            // Pokéball watermark pattern
            GeometryReader { geo in
                Canvas { context, size in
                    let spacing: CGFloat = 80
                    let dotSize: CGFloat = 3

                    for row in stride(from: CGFloat(-20), to: size.height + 40, by: spacing) {
                        let offset: CGFloat = (Int(row / spacing) % 2 == 0) ? 0 : spacing / 2
                        for col in stride(from: CGFloat(-20) + offset, to: size.width + 40, by: spacing) {
                            // Tiny pokéball icon
                            let cx = col
                            let cy = row
                            let r: CGFloat = 8

                            // Top half (red-ish)
                            var topPath = Path()
                            topPath.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            topPath.closeSubpath()
                            context.fill(topPath, with: .color(Color.fireRed.opacity(0.04)))

                            // Bottom half
                            var bottomPath = Path()
                            bottomPath.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                            bottomPath.closeSubpath()
                            context.fill(bottomPath, with: .color(Color.black.opacity(0.02)))

                            // Center line
                            let linePath = Path(CGRect(x: cx - r, y: cy - 0.5, width: r * 2, height: 1))
                            context.fill(linePath, with: .color(Color.black.opacity(0.03)))

                            // Center dot
                            let dotRect = CGRect(x: cx - dotSize/2, y: cy - dotSize/2, width: dotSize, height: dotSize)
                            context.fill(Path(ellipseIn: dotRect), with: .color(Color.black.opacity(0.04)))

                            // Circle outline
                            context.stroke(
                                Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                                with: .color(Color.black.opacity(0.03)),
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
