//
//  ContributionsGrid.swift
//  InterfaceKit
//

import SwiftUI
import WidgetKit

/// A contribution graph that fills the space it is given with square days of one size.
///
/// The day size comes from the height, and the number of weeks from the width at that size, rounded up so the
/// days shrink slightly to fit rather than leave a gap. Days are snapped to whole pixels so every one draws the same,
/// and the gaps between weeks take up the remainder so the graph spans the full width. Gaps and corner radius scale
/// with the day size, so the graph keeps its proportions from a Lock Screen widget to an iPad.
public struct ContributionsGrid: View {
    // MARK: - Properties

    let calendar: ContributionCalendar
    let theme: ContributionsTheme
    let weekRows: Int
    let spacingRatio: CGFloat

    @Environment(\.displayScale)
    private var displayScale

    @Environment(\.widgetRenderingMode)
    private var widgetRenderingMode

    /// Fill opacity per level when the system tints the widget (tinted and clear Home Screens, the Lock Screen,
    /// StandBy at night). Those modes keep only alpha, so the levels need their own evenly spaced opacities.
    private static let monochromeOpacities: [Double] = [0.18, 0.4, 0.6, 0.8, 1]

    // MARK: - Init

    /// Creates a graph of the most recent weeks of `calendar` that fit.
    ///
    /// - Parameters:
    ///   - weekRows: How many rows of weeks to wrap the graph into, oldest row first. Tall spaces use more than one
    ///     to show more weeks at a size that fills them.
    ///   - spacing: The gap between days as a fraction of the day size.
    public init(calendar: ContributionCalendar, theme: ContributionsTheme = .green, weekRows: Int = 1, spacing: CGFloat = 0.24) {
        self.calendar = calendar
        self.theme = theme
        self.weekRows = max(weekRows, 1)
        self.spacingRatio = spacing
    }

    // MARK: - View

    public var body: some View {
        GeometryReader { proxy in
            let layout = ContributionsGridLayout(
                size: proxy.size,
                weekCount: calendar.weekCount,
                weekRows: weekRows,
                spacingRatio: spacingRatio,
                scale: displayScale
            )
            let tiles = layout.tiles(for: calendar)
            ZStack(alignment: .topLeading) {
                ForEach(tiles.indices, id: \.self) { level in
                    TilesShape(rects: tiles[level], cornerRadius: layout.cornerRadius)
                        .fill(fill(forLevel: level))
                        .widgetAccentable(level > 0)
                }
            }
            // The shapes say nothing to VoiceOver, so the graph reads as one element that summarizes the days shown.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("contributions-graph", bundle: .module))
            .accessibilityValue(Self.accessibilityValue(for: tiles))
        }
    }

    // MARK: - Private

    /// How many of the days shown have contributions, out of all the days shown.
    private static func accessibilityValue(for tiles: [[CGRect]]) -> Text {
        let shownDays = tiles.reduce(0) { $0 + $1.count }
        let activeDays = shownDays - (tiles.first?.count ?? 0)
        return Text("contributions-graph-active-days \(activeDays) \(shownDays)", bundle: .module)
    }

    private func fill(forLevel level: Int) -> Color {
        guard widgetRenderingMode == .fullColor else {
            return .white.opacity(Self.monochromeOpacities[min(level, Self.monochromeOpacities.count - 1)])
        }
        return theme.color(forLevel: level)
    }
}
