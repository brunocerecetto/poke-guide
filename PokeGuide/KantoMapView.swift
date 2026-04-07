//
//  KantoMapView.swift
//  PokeGuide
//
//  Mapa estilo metro de Kanto con fondo pixel art de la isla.
//

import SwiftUI

// MARK: - Data

private enum LabelAlign { case top, bottom, leading, trailing }
private enum CityType { case gym, town, poi }

private struct MapCity: Identifiable {
    let id: String
    let name: String
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let type: CityType
    let label: LabelAlign
}

private struct MapRoute: Identifiable {
    let id: String
    let points: [(CGFloat, CGFloat)]
    let routeLabel: String
    let isWater: Bool
    let routeNumbers: [Int]
}

// MARK: - Location Mapper

enum KantoLocationMapper {
    static func mapLocationToIDs(_ location: String) -> Set<String> {
        var ids = Set<String>()
        let loc = location.lowercased()

        let routePattern = /[Rr]uta\s+(\d+)/
        for match in loc.matches(of: routePattern) {
            ids.insert("r\(Int(match.1)!)")
        }

        let areaMap: [(String, String)] = [
            ("pueblo paleta", "pallet"), ("paleta", "pallet"),
            ("viridian", "viridian"), ("ciudad verde", "viridian"), ("c. verde", "viridian"),
            ("pewter", "pewter"), ("ciudad plateada", "pewter"), ("c. plateada", "pewter"),
            ("cerulean", "cerulean"), ("ciudad celeste", "cerulean"), ("c. celeste", "cerulean"),
            ("cueva celeste", "cerulean"),
            ("vermilion", "vermilion"), ("ciudad carmín", "vermilion"), ("c. carmín", "vermilion"),
            ("celadon", "celadon"), ("ciudad azulona", "celadon"), ("c. azulona", "celadon"),
            ("saffron", "saffron"), ("ciudad azafrán", "saffron"), ("c. azafrán", "saffron"),
            ("silph", "saffron"),
            ("lavanda", "lavender"), ("pueblo lavanda", "lavender"), ("p. lavanda", "lavender"),
            ("torre pokémon", "lavender"),
            ("fucsia", "fuchsia"), ("ciudad fucsia", "fuchsia"), ("c. fucsia", "fuchsia"),
            ("safari", "fuchsia"), ("zona safari", "fuchsia"),
            ("isla canela", "cinnabar"), ("canela", "cinnabar"), ("cinnabar", "cinnabar"),
            ("meseta añil", "indigo"), ("indigo", "indigo"),
            ("bosque viridian", "viridianforest"), ("bosque verde", "viridianforest"),
            ("cueva luna", "mtmoon"), ("mt. moon", "mtmoon"), ("monte luna", "mtmoon"),
            ("cueva pokémon", "rocktunnel"), ("túnel roca", "rocktunnel"),
            ("planta de energía", "powerplant"), ("central eléctrica", "powerplant"),
            ("cueva diglett", "diglettcave"), ("diglett", "diglettcave"),
            ("islas espuma", "seafoam"), ("seafoam", "seafoam"),
            ("camino victoria", "victoryroad"), ("victory road", "victoryroad"),
        ]

        for (keyword, cityId) in areaMap where loc.contains(keyword) {
            ids.insert(cityId)
        }
        return ids
    }
}

// MARK: - Kanto Cities & Routes

private let kantoCities: [MapCity] = [
    // Gyms
    MapCity(id: "pewter",    name: "Pewter",       x: 2,   y: 1,   color: Color(red: 0.71, green: 0.63, blue: 0.38), type: .gym, label: .bottom),
    MapCity(id: "cerulean",  name: "Cerulean",     x: 5,   y: 0,   color: Color(red: 0.39, green: 0.56, blue: 0.94), type: .gym, label: .top),
    MapCity(id: "viridian",  name: "Viridian",     x: 1,   y: 5,   color: Color(red: 0.47, green: 0.78, blue: 0.30), type: .gym, label: .trailing),
    MapCity(id: "celadon",   name: "Celadon",      x: 3,   y: 5,   color: Color(red: 0.20, green: 0.60, blue: 0.30), type: .gym, label: .top),
    MapCity(id: "saffron",   name: "Saffron",      x: 5,   y: 5,   color: Color(red: 0.98, green: 0.33, blue: 0.53), type: .gym, label: .top),
    MapCity(id: "vermilion", name: "Vermilion",    x: 5,   y: 7,   color: .orange, type: .gym, label: .leading),
    MapCity(id: "fuchsia",   name: "Fuchsia",      x: 4,   y: 9,   color: .pink, type: .gym, label: .bottom),
    MapCity(id: "cinnabar",  name: "Cinnabar",     x: 1,   y: 10,  color: Color(red: 0.85, green: 0.20, blue: 0.10), type: .gym, label: .leading),
    // Towns
    MapCity(id: "indigo",    name: "Meseta Añil",  x: 0,   y: 0,   color: .purple, type: .town, label: .trailing),
    MapCity(id: "lavender",  name: "Lavender",     x: 7,   y: 5,   color: .purple, type: .town, label: .trailing),
    MapCity(id: "pallet",    name: "Pallet",       x: 1,   y: 7.5, color: Color(red: 0.88, green: 0.18, blue: 0.18), type: .town, label: .trailing),
    // POIs
    MapCity(id: "victoryroad",   name: "Victory Rd",  x: 0,   y: 2,   color: .gray, type: .poi, label: .trailing),
    MapCity(id: "viridianforest",name: "Bosque Verde", x: 1,   y: 3,   color: Color(red: 0.30, green: 0.55, blue: 0.20), type: .poi, label: .trailing),
    MapCity(id: "diglettcave",   name: "C. Diglett",   x: 2.5, y: 2,   color: Color(red: 0.55, green: 0.40, blue: 0.25), type: .poi, label: .bottom),
    MapCity(id: "mtmoon",        name: "Mt. Moon",     x: 3,   y: 0,   color: .gray, type: .poi, label: .top),
    MapCity(id: "rocktunnel",    name: "Túnel Roca",   x: 7,   y: 1.5, color: .gray, type: .poi, label: .leading),
    MapCity(id: "powerplant",    name: "Central",      x: 7,   y: 3,   color: Color(red: 0.97, green: 0.82, blue: 0.17), type: .poi, label: .leading),
    MapCity(id: "seafoam",       name: "I. Espuma",    x: 3,   y: 10,  color: Color(red: 0.58, green: 0.85, blue: 0.84), type: .poi, label: .bottom),
]

private let kantoRoutes: [MapRoute] = [
    MapRoute(id: "r22", points: [(1, 5), (0, 5), (0, 2)],             routeLabel: "22-23", isWater: false, routeNumbers: [22, 23]),
    MapRoute(id: "r23", points: [(0, 2), (0, 0)],                     routeLabel: "23",    isWater: false, routeNumbers: [23]),
    MapRoute(id: "r2",  points: [(1, 5), (1, 3)],                     routeLabel: "2",     isWater: false, routeNumbers: [2]),
    MapRoute(id: "r2b", points: [(1, 3), (2, 2), (2, 1)],            routeLabel: "",      isWater: false, routeNumbers: [2]),
    MapRoute(id: "r3",  points: [(2, 1), (3, 0)],                     routeLabel: "3",     isWater: false, routeNumbers: [3]),
    MapRoute(id: "r4",  points: [(3, 0), (5, 0)],                     routeLabel: "4",     isWater: false, routeNumbers: [4]),
    MapRoute(id: "r24", points: [(5, 0), (5, -0.8)],                  routeLabel: "24-25", isWater: false, routeNumbers: [24, 25]),
    MapRoute(id: "r5",  points: [(5, 0), (5, 5)],                     routeLabel: "5",     isWater: false, routeNumbers: [5]),
    MapRoute(id: "r9",  points: [(5, 0), (7, 0), (7, 1.5)],         routeLabel: "9",     isWater: false, routeNumbers: [9]),
    MapRoute(id: "r10", points: [(7, 1.5), (7, 3), (7, 5)],         routeLabel: "10",    isWater: false, routeNumbers: [10]),
    MapRoute(id: "r7",  points: [(3, 5), (5, 5)],                     routeLabel: "7",     isWater: false, routeNumbers: [7]),
    MapRoute(id: "r16", points: [(3, 5), (3, 9), (4, 9)],            routeLabel: "16-18", isWater: false, routeNumbers: [16, 17, 18]),
    MapRoute(id: "r8",  points: [(5, 5), (7, 5)],                     routeLabel: "8",     isWater: false, routeNumbers: [8]),
    MapRoute(id: "r6",  points: [(5, 5), (5, 7)],                     routeLabel: "6",     isWater: false, routeNumbers: [6]),
    MapRoute(id: "r11", points: [(5, 7), (7, 7)],                     routeLabel: "11",    isWater: false, routeNumbers: [11]),
    MapRoute(id: "r12", points: [(7, 5), (7, 9), (4, 9)],            routeLabel: "12-15", isWater: false, routeNumbers: [12, 13, 14, 15]),
    MapRoute(id: "r1",  points: [(1, 5), (1, 7.5)],                   routeLabel: "1",     isWater: false, routeNumbers: [1]),
    MapRoute(id: "r21", points: [(1, 7.5), (1, 10)],                  routeLabel: "21",    isWater: true,  routeNumbers: [21]),
    MapRoute(id: "r19", points: [(1, 10), (3, 10)],                   routeLabel: "20",    isWater: true,  routeNumbers: [20]),
    MapRoute(id: "r20", points: [(3, 10), (4, 10), (4, 9)],          routeLabel: "19",    isWater: true,  routeNumbers: [19]),
]

// MARK: - Pixel Art Terrain

private enum Terrain {
    case deepWater, shallowWater, beach, land, forest, mountain
}

private func pxHash(_ col: Int, _ row: Int) -> Int {
    var h = col &* 374761393 &+ row &* 668265263
    h = (h ^ (h >> 13)) &* 1274126177
    return abs(h ^ (h >> 16))
}

private func isLand(_ gx: CGFloat, _ gy: CGFloat) -> Bool {
    if gy >= -1.5 && gy <= 5.5 && gx >= -0.8 && gx <= 7.8 { return true }
    if gx >= -0.3 && gx <= 2.0 && gy > 5.5 && gy <= 8.5 { return true }
    if gx >= 2.5 && gx <= 3.8 && gy > 5.5 && gy <= 9.5 { return true }
    if gx >= 4.5 && gx <= 5.8 && gy > 5.5 && gy <= 7.8 { return true }
    if gx >= 5.5 && gx <= 7.8 && gy >= 6.5 && gy <= 7.8 { return true }
    if gx >= 6.8 && gx <= 8.0 && gy > 5.5 && gy <= 9.8 { return true }
    if gx >= 3.5 && gx <= 8.0 && gy >= 8.5 && gy <= 10.0 { return true }
    if gx >= 0.3 && gx <= 1.8 && gy >= 9.5 && gy <= 10.8 { return true }
    if gx >= 2.5 && gx <= 3.5 && gy >= 9.8 && gy <= 10.6 { return true }
    return false
}

private func terrain(_ gx: CGFloat, _ gy: CGFloat, col: Int, row: Int) -> Terrain {
    let h = pxHash(col, row)
    // Coastline noise: jitter the boundary slightly
    let nx = gx + CGFloat(h % 5) * 0.06 - 0.15
    let ny = gy + CGFloat((h >> 4) % 5) * 0.06 - 0.15

    guard isLand(nx, ny) else {
        // Beach: land pixel next to water
        for d: CGFloat in [-0.35, 0, 0.35] {
            if isLand(gx + d, gy) || isLand(gx, gy + d) { return .beach }
        }
        // Shallow water near coast
        for d: CGFloat in [-0.7, 0, 0.7] {
            if isLand(gx + d, gy) || isLand(gx, gy + d) { return .shallowWater }
        }
        return .deepWater
    }

    // Bay carve-out
    let bayNx = gx + CGFloat(h % 4) * 0.08 - 0.16
    if bayNx >= 1.8 && bayNx <= 2.8 && gy >= 6.5 && gy <= 9.5 { return .deepWater }
    if gx >= 3.8 && gx <= 5.0 && gy >= 7.8 && gy <= 8.8 { return .shallowWater }

    // Mountains
    if gy <= 1.5 && gx <= 1.5 { return .mountain }
    if gy <= 1.0 && gx >= 2.0 && gx <= 4.5 { return .mountain }
    if gy <= 0.5 && gx >= 6.5 { return .mountain }

    // Forests
    if gx >= 0.3 && gx <= 2.3 && gy >= 2.0 && gy <= 4.5 { return .forest }
    if gx >= 3.5 && gx <= 5.0 && gy >= 8.8 && gy <= 9.8 { return .forest }

    return .land
}

/// Per-pixel textured color based on terrain + position
private func pixelColor(_ t: Terrain, _ col: Int, _ row: Int) -> Color {
    let h = pxHash(col, row)
    let v = h % 100

    switch t {
    case .deepWater:
        let wave = (col + row) % 7
        if wave < 2 { return Color(red: 0.18, green: 0.40, blue: 0.65) }
        if v < 3 { return Color(red: 0.48, green: 0.70, blue: 0.90) }
        return Color(red: 0.25, green: 0.48, blue: 0.75)

    case .shallowWater:
        let wave = (col + row) % 5
        if wave == 0 { return Color(red: 0.30, green: 0.56, blue: 0.78) }
        if v < 6 { return Color(red: 0.52, green: 0.76, blue: 0.92) }
        return Color(red: 0.38, green: 0.64, blue: 0.85)

    case .beach:
        if v < 12 { return Color(red: 0.90, green: 0.84, blue: 0.62) }
        if v < 25 { return Color(red: 0.78, green: 0.72, blue: 0.52) }
        return Color(red: 0.85, green: 0.78, blue: 0.56)

    case .land:
        // Grass tufts: 3×3 pattern with darker centers
        let tx = col % 3, ty = row % 3
        if tx == 1 && ty == 1 && v < 35 {
            return Color(red: 0.38, green: 0.64, blue: 0.28)
        }
        if v < 6 { return Color(red: 0.56, green: 0.82, blue: 0.44) }
        if v < 10 { return Color(red: 0.50, green: 0.60, blue: 0.36) }
        return Color(red: 0.45, green: 0.72, blue: 0.34)

    case .forest:
        // Tree canopies: 4×4 tiles with dark core
        let tx = col % 4, ty = row % 4
        let isCore = (tx == 1 || tx == 2) && (ty == 1 || ty == 2)
        if isCore {
            return v < 40
                ? Color(red: 0.10, green: 0.32, blue: 0.08)
                : Color(red: 0.16, green: 0.40, blue: 0.12)
        }
        if v < 15 { return Color(red: 0.30, green: 0.56, blue: 0.22) }
        return Color(red: 0.22, green: 0.48, blue: 0.16)

    case .mountain:
        // Rocky ridges: diagonal lines
        let ridge = (col + row * 2) % 5
        if ridge == 0 { return Color(red: 0.45, green: 0.43, blue: 0.40) }
        if v < 12 { return Color(red: 0.68, green: 0.66, blue: 0.62) }
        if v < 22 { return Color(red: 0.54, green: 0.48, blue: 0.38) }
        return Color(red: 0.58, green: 0.55, blue: 0.50)
    }
}

// MARK: - View

struct KantoMapView: View {
    @Environment(\.themeColors) private var theme
    var highlightIDs: Set<String> = []

    private let maxCol: CGFloat = 7.8
    private let maxRow: CGFloat = 11.5
    private let inset: CGFloat = 30
    private var hasHighlight: Bool { !highlightIDs.isEmpty }

    var body: some View {
        GeometryReader { geo in
            let cellW = (geo.size.width - inset * 2) / maxCol
            let cellH = cellW * 0.7
            let mapH = cellH * maxRow + inset * 2

            ScrollView {
                VStack(spacing: KASpacing.md) {
                    ZStack(alignment: .topLeading) {
                        // Layer 1: Pixel art terrain
                        terrainCanvas(width: geo.size.width, height: mapH, cellW: cellW, cellH: cellH)

                        // Layer 2: Route lines
                        ForEach(kantoRoutes) { route in
                            routePath(route, cellW: cellW, cellH: cellH)
                        }
                        ForEach(kantoRoutes.filter { !$0.routeLabel.isEmpty }) { route in
                            routeTag(route, cellW: cellW, cellH: cellH)
                        }

                        // Layer 3: City dots + labels
                        ForEach(kantoCities) { city in
                            cityDot(city, cellW: cellW, cellH: cellH)
                            cityLabel(city, cellW: cellW, cellH: cellH)
                        }
                    }
                    .frame(width: geo.size.width, height: mapH)
                    .clipShape(RoundedRectangle(cornerRadius: KARadius.lg))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)

                    legend
                }
            }
        }
    }

    // MARK: - Pixel Art Canvas

    private func terrainCanvas(width: CGFloat, height: CGFloat, cellW: CGFloat, cellH: CGFloat) -> some View {
        Canvas { context, size in
            let px: CGFloat = 7
            let cols = Int(ceil(size.width / px))
            let rows = Int(ceil(size.height / px))

            for row in 0..<rows {
                for col in 0..<cols {
                    let sx = CGFloat(col) * px
                    let sy = CGFloat(row) * px
                    let gx = (sx - inset) / cellW
                    let gy = (sy - inset) / cellH - 1

                    let t = terrain(gx, gy, col: col, row: row)
                    let color = pixelColor(t, col, row)
                    context.fill(
                        Path(CGRect(x: sx, y: sy, width: px + 0.5, height: px + 0.5)),
                        with: .color(color)
                    )
                }
            }
        }
        .frame(width: width, height: height)
        .drawingGroup()
    }

    // MARK: - Coordinate Helper

    private func pt(_ x: CGFloat, _ y: CGFloat, cellW: CGFloat, cellH: CGFloat) -> CGPoint {
        CGPoint(x: inset + x * cellW, y: inset + (y + 1) * cellH)
    }

    private func isRouteHighlighted(_ route: MapRoute) -> Bool {
        guard hasHighlight else { return false }
        return route.routeNumbers.contains { num in highlightIDs.contains("r\(num)") }
    }

    private func isCityHighlighted(_ city: MapCity) -> Bool {
        guard hasHighlight else { return false }
        return highlightIDs.contains(city.id)
    }

    // MARK: - Routes

    private func routePath(_ route: MapRoute, cellW: CGFloat, cellH: CGFloat) -> some View {
        let highlighted = isRouteHighlighted(route)
        let opacity: Double = hasHighlight ? (highlighted ? 0.9 : 0.15) : 0.55

        return Path { path in
            for (i, p) in route.points.enumerated() {
                let point = pt(p.0, p.1, cellW: cellW, cellH: cellH)
                if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
        }
        .stroke(
            route.isWater ? Color.white.opacity(opacity * 0.7) : Color.white.opacity(opacity),
            style: StrokeStyle(
                lineWidth: highlighted ? 5 : 3,
                lineCap: .round,
                lineJoin: .round,
                dash: route.isWater ? [6, 4] : []
            )
        )
        .shadow(color: .black.opacity(0.15), radius: 1)
        .animation(.easeInOut(duration: 0.3), value: highlighted)
    }

    private func routeTag(_ route: MapRoute, cellW: CGFloat, cellH: CGFloat) -> some View {
        let mid = routeMidpoint(route.points, cellW: cellW, cellH: cellH)
        let highlighted = isRouteHighlighted(route)
        let dimmed = hasHighlight && !highlighted

        return Text(route.routeLabel)
            .font(.system(size: 7, weight: .heavy, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 3)
            .padding(.vertical, 1)
            .background(RoundedRectangle(cornerRadius: 2).fill(Color.black.opacity(dimmed ? 0.1 : 0.35)))
            .opacity(dimmed ? 0.2 : 1)
            .position(x: mid.x + 8, y: mid.y - 7)
    }

    private func routeMidpoint(_ points: [(CGFloat, CGFloat)], cellW: CGFloat, cellH: CGFloat) -> CGPoint {
        let idx = points.count > 2 ? 1 : 0
        let p1 = pt(points[idx].0, points[idx].1, cellW: cellW, cellH: cellH)
        let p2 = pt(points[idx + 1].0, points[idx + 1].1, cellW: cellW, cellH: cellH)
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    // MARK: - Cities

    private func cityDot(_ city: MapCity, cellW: CGFloat, cellH: CGFloat) -> some View {
        let pos = pt(city.x, city.y, cellW: cellW, cellH: cellH)
        let highlighted = isCityHighlighted(city)
        let dimmed = hasHighlight && !highlighted
        let size: CGFloat = highlighted ? 16 : (city.type == .gym ? 12 : (city.type == .town ? 10 : 7))

        return ZStack {
            if highlighted {
                Circle().fill(Color.white.opacity(0.3))
                    .frame(width: 26, height: 26)
            }
            Circle().fill(city.color)
                .frame(width: size, height: size)
            if city.type == .gym {
                Circle().stroke(Color.white, lineWidth: 2)
                    .frame(width: size, height: size)
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 2)
        .opacity(dimmed ? 0.3 : 1)
        .position(pos)
        .animation(.easeInOut(duration: 0.3), value: highlighted)
    }

    private func cityLabel(_ city: MapCity, cellW: CGFloat, cellH: CGFloat) -> some View {
        let pos = pt(city.x, city.y, cellW: cellW, cellH: cellH)
        let offset = labelOffset(city.label)
        let highlighted = isCityHighlighted(city)
        let dimmed = hasHighlight && !highlighted
        let isPoi = city.type == .poi

        return Text(city.name)
            .font(.system(size: highlighted ? 10 : (isPoi ? 7 : 9), weight: highlighted ? .heavy : (isPoi ? .semibold : .bold)))
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 1.5)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(isPoi ? 0.4 : 0.55))
            )
            .fixedSize()
            .opacity(dimmed ? 0.2 : 1)
            .position(x: pos.x + offset.width, y: pos.y + offset.height)
    }

    private func labelOffset(_ align: LabelAlign) -> CGSize {
        switch align {
        case .top:      return CGSize(width: 0, height: -14)
        case .bottom:   return CGSize(width: 0, height: 14)
        case .leading:  return CGSize(width: -35, height: 0)
        case .trailing: return CGSize(width: 38, height: 0)
        }
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: KASpacing.md) {
            legendDot(color: .pink, stroke: true, label: "Gimnasio")
            legendDot(color: .purple, stroke: false, label: "Pueblo")
            legendDot(color: .gray, stroke: false, label: "Punto de interés")
        }
        .padding(.horizontal)
    }

    private func legendDot(color: Color, stroke: Bool, label: String) -> some View {
        HStack(spacing: 3) {
            ZStack {
                Circle().fill(color).frame(width: 8, height: 8)
                if stroke { Circle().stroke(Color.white, lineWidth: 1.5).frame(width: 8, height: 8) }
            }
            Text(label).font(KATypography.labelXs).foregroundColor(.onSurfaceVariant)
        }
    }
}

#Preview {
    KantoMapView(highlightIDs: ["r3", "viridianforest"])
}
