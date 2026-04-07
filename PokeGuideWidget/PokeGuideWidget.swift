//
//  PokeGuideWidget.swift
//  PokeGuideWidget
//
//  Widget extension que muestra el progreso de la guia.
//

import WidgetKit
import SwiftUI

// MARK: - Shared Constants

private enum SharedKeys {
    static let appGroup = "group.com.brunocerecetto.PokeGuide"
    static let versionKey = "gameVersion"
    static let starterKey = "selectedStarter"

    static func prefix(for defaults: UserDefaults) -> String {
        let version = defaults.string(forKey: versionKey) ?? "fireRed"
        let starter = defaults.string(forKey: starterKey) ?? "squirtle"
        return "\(version)_\(starter)"
    }

    static func gymKey(_ prefix: String) -> String { "\(prefix)_completedGyms" }
    static func routeKey(_ prefix: String) -> String { "\(prefix)_completedRouteSteps" }
    static func leagueKey(_ prefix: String) -> String { "\(prefix)_completedLeague" }
    static func preLeagueKey(_ prefix: String) -> String { "\(prefix)_completedPreLeague" }
    static func postgameKey(_ prefix: String) -> String { "\(prefix)_completedPostgame" }
}

// MARK: - Data counts (must match GameData)

private enum GameCounts {
    static let gyms = 8
    static let routeSteps = 85
    static let eliteFour = 5
    static let preLeague = 11
    static let postgame = 7
    static let total = gyms + routeSteps + eliteFour + preLeague + postgame
}

// MARK: - Widget Entry

struct ProgressEntry: TimelineEntry {
    let date: Date
    let completedGyms: Int
    let completedRouteSteps: Int
    let completedLeague: Int
    let completedPreLeague: Int
    let completedPostgame: Int
    let gameVersion: String
    let starterEmoji: String
    let nextRouteSteps: [String]

    var totalCompleted: Int {
        completedGyms + completedRouteSteps + completedLeague + completedPreLeague + completedPostgame
    }

    var totalCheckable: Int { GameCounts.total }

    var fraction: Double {
        guard totalCheckable > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalCheckable)
    }

    var percentText: String {
        "\(Int(fraction * 100))%"
    }

    var isFireRed: Bool { gameVersion == "fireRed" }

    static let placeholder = ProgressEntry(
        date: .now,
        completedGyms: 3,
        completedRouteSteps: 28,
        completedLeague: 0,
        completedPreLeague: 4,
        completedPostgame: 0,
        gameVersion: "fireRed",
        starterEmoji: "🐢",
        nextRouteSteps: ["Capturar Snorlax en Route 12", "Surf a Cinnabar Island", "Gym de Blaine"]
    )
}

// MARK: - Timeline Provider

struct ProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProgressEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ProgressEntry) -> Void) {
        completion(context.isPreview ? .placeholder : readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgressEntry>) -> Void) {
        let entry = readEntry()
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func readEntry() -> ProgressEntry {
        guard let defaults = UserDefaults(suiteName: SharedKeys.appGroup) else {
            return .placeholder
        }

        let prefix = SharedKeys.prefix(for: defaults)
        let version = defaults.string(forKey: SharedKeys.versionKey) ?? "fireRed"
        let starter = defaults.string(forKey: SharedKeys.starterKey) ?? "squirtle"

        let gyms = defaults.stringArray(forKey: SharedKeys.gymKey(prefix)) ?? []
        let routes = defaults.stringArray(forKey: SharedKeys.routeKey(prefix)) ?? []
        let league = defaults.stringArray(forKey: SharedKeys.leagueKey(prefix)) ?? []
        let preLeague = defaults.stringArray(forKey: SharedKeys.preLeagueKey(prefix)) ?? []
        let postgame = defaults.stringArray(forKey: SharedKeys.postgameKey(prefix)) ?? []

        // Read next uncompleted route step descriptions from a cached array
        let nextSteps = defaults.stringArray(forKey: "\(prefix)_nextRouteSteps") ?? []

        let starterEmoji: String = {
            switch starter {
            case "bulbasaur":  return "🌿"
            case "charmander": return "🔥"
            case "squirtle":   return "🐢"
            default:           return "🐢"
            }
        }()

        return ProgressEntry(
            date: .now,
            completedGyms: gyms.count,
            completedRouteSteps: routes.count,
            completedLeague: league.count,
            completedPreLeague: preLeague.count,
            completedPostgame: postgame.count,
            gameVersion: version,
            starterEmoji: starterEmoji,
            nextRouteSteps: Array(nextSteps.prefix(3))
        )
    }
}

// MARK: - Colors (synced with Theme.swift "The Kinetic Archive" design system)

private extension Color {
    static let widgetPrimary = Color(red: 0.737, green: 0.004, blue: 0.0)        // #bc0100
    static let widgetPrimaryContainer = Color(red: 0.922, green: 0.0, blue: 0.0) // #eb0000
    static let widgetLeafGreen = Color(red: 0.18, green: 0.65, blue: 0.32)
    static let widgetSurface = Color(red: 0.976, green: 0.976, blue: 0.976)       // #f9f9f9
    static let widgetTextPrimary = Color(red: 0.102, green: 0.110, blue: 0.110)   // #1a1c1c
    static let widgetTextSecondary = Color(red: 0.247, green: 0.286, blue: 0.282) // #3f4948
}

// MARK: - Progress Ring

private struct ProgressRing: View {
    let fraction: Double
    let accentColor: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(accentColor.opacity(0.15), lineWidth: size * 0.12)

            Circle()
                .trim(from: 0, to: CGFloat(fraction))
                .stroke(
                    AngularGradient(
                        colors: [accentColor, accentColor.opacity(0.7), accentColor],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: size * 0.12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("\(Int(fraction * 100))%")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundColor(.widgetTextPrimary)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Small Widget View

private struct SmallWidgetView: View {
    let entry: ProgressEntry

    private var accent: Color {
        entry.isFireRed ? .widgetPrimary : .widgetLeafGreen
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: entry.isFireRed ? "flame.fill" : "leaf.fill")
                    .font(.caption2)
                    .foregroundColor(accent)
                Text("PokeGuide")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.widgetTextSecondary)
            }

            ProgressRing(fraction: entry.fraction, accentColor: accent, size: 72)

            Text("\(entry.totalCompleted)/\(entry.totalCheckable) pasos")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.widgetTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color.widgetSurface
        }
    }
}

// MARK: - Medium Widget View

private struct MediumWidgetView: View {
    let entry: ProgressEntry

    private var accent: Color {
        entry.isFireRed ? .widgetPrimary : .widgetLeafGreen
    }

    private var secondaryAccent: Color {
        entry.isFireRed ? .widgetPrimaryContainer : .widgetLeafGreen.opacity(0.7)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left: progress ring + stats
            VStack(spacing: 6) {
                ProgressRing(fraction: entry.fraction, accentColor: accent, size: 68)

                HStack(spacing: 8) {
                    badgePill(
                        icon: "shield.fill",
                        text: "\(entry.completedGyms)/\(GameCounts.gyms)",
                        color: accent
                    )
                    badgePill(
                        icon: "star.fill",
                        text: "\(entry.completedLeague)/\(GameCounts.eliteFour)",
                        color: secondaryAccent
                    )
                }
            }
            .frame(width: 120)

            // Right: next steps
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(entry.starterEmoji)
                        .font(.caption)
                    Text("Siguientes pasos")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.widgetTextPrimary)
                }

                if entry.nextRouteSteps.isEmpty {
                    VStack(spacing: 2) {
                        Text(entry.fraction >= 1.0 ? "Completado!" : "Sin pasos pendientes")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.widgetTextSecondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ForEach(Array(entry.nextRouteSteps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 4) {
                            Circle()
                                .fill(accent.opacity(0.6))
                                .frame(width: 5, height: 5)
                                .padding(.top, 4)

                            Text(step)
                                .font(.system(size: 10, weight: .regular, design: .rounded))
                                .foregroundColor(.widgetTextPrimary)
                                .lineLimit(2)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color.widgetSurface
        }
    }

    private func badgePill(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
            Text(text)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Widget Definition

struct PokeGuideWidget: Widget {
    let kind: String = "PokeGuideWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProgressProvider()) { entry in
            PokeGuideWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Progreso PokeGuide")
        .description("Tu progreso en la guia de Pokemon FireRed / LeafGreen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PokeGuideWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: ProgressEntry

    var body: some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle (entry point)

@main
struct PokeGuideWidgetBundle: WidgetBundle {
    var body: some Widget {
        PokeGuideWidget()
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    PokeGuideWidget()
} timeline: {
    ProgressEntry.placeholder
}

#Preview("Medium", as: .systemMedium) {
    PokeGuideWidget()
} timeline: {
    ProgressEntry.placeholder
}
