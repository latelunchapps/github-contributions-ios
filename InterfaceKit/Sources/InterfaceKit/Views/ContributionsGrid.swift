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
        }
    }

    // MARK: - Private

    private func fill(forLevel level: Int) -> Color {
        guard widgetRenderingMode == .fullColor else {
            return .white.opacity(Self.monochromeOpacities[min(level, Self.monochromeOpacities.count - 1)])
        }
        return theme.color(forLevel: level)
    }
}

// MARK: -

/// Where each day of a contribution graph goes.
struct ContributionsGridLayout {
    // MARK: - Properties

    /// Weeks per row of weeks.
    private(set) var columns = 0
    private(set) var weekRows = 0
    private(set) var tileSize: CGFloat = 0
    private(set) var cornerRadius: CGFloat = 0
    private(set) var rowSpacing: CGFloat = 0
    private(set) var weekRowSpacing: CGFloat = 0
    /// The leading edge of each week.
    private(set) var columnOffsets: [CGFloat] = []
    /// The top edge of the first row of days.
    private(set) var top: CGFloat = 0

    /// The corner radius as a fraction of the day size.
    static let cornerRatio: CGFloat = 0.25
    /// The gap between rows of weeks as a fraction of the day size.
    static let weekRowSpacingRatio: CGFloat = 1

    private static let days = CGFloat(ContributionCalendar.daysPerWeek)

    // MARK: - Init

    init(size: CGSize, weekCount: Int, weekRows: Int, spacingRatio: CGFloat, scale: CGFloat) {
        guard size.width > 0, size.height > 0, weekCount > 0 else { return }
        let scale = max(scale, 1)
        let ratio = max(spacingRatio, 0)
        let weekRows = max(1, min(weekRows, weekCount))
        let rows = CGFloat(weekRows)

        // 1. The largest day the height allows, then as many weeks as that size needs to fill the width,
        // rounded up so the days shrink to fit rather than leave a gap. There may be fewer weeks than that.
        let maxTile = size.height / (rows * (Self.days + (Self.days - 1) * ratio) + (rows - 1) * Self.weekRowSpacingRatio)
        let fitting = Int(((size.width + ratio * maxTile) / (maxTile * (1 + ratio))).rounded(.up))
        let columns = max(1, min(fitting, weekCount / weekRows))
        let idealTile = min(maxTile, size.width / (CGFloat(columns) + CGFloat(columns - 1) * ratio))

        // 2. Snap the day size and gaps to whole pixels, so every day draws the same.
        let pixel = 1 / scale
        let tile = (idealTile * scale).rounded(.down) / scale
        guard tile >= pixel else { return }
        var rowSpacing = max(pixel, (tile * ratio * scale).rounded() / scale)
        let weekRowSpacing = (tile * Self.weekRowSpacingRatio * scale).rounded() / scale
        func height(_ rowSpacing: CGFloat) -> CGFloat {
            rows * (Self.days * tile + (Self.days - 1) * rowSpacing) + (rows - 1) * weekRowSpacing
        }
        while height(rowSpacing) > size.height, rowSpacing > pixel {
            rowSpacing -= pixel
        }

        // 3. Spread the weeks across the full width. The gaps between weeks absorb the pixels left over from
        // snapping, so they differ from the row spacing by a pixel at most. If there are too few weeks to fill the
        // width, keep the row spacing and line the latest week up with the trailing edge.
        let widthPixels = (size.width * scale).rounded(.down)
        let tilePixels = (tile * scale).rounded()
        let offsets: [CGFloat]
        let stretchedGap = columns > 1 ? (widthPixels - CGFloat(columns) * tilePixels) / CGFloat(columns - 1) / scale : 0
        if columns > 1, stretchedGap <= rowSpacing + 2 * pixel + 0.001 {
            let pitch = (widthPixels - tilePixels) / CGFloat(columns - 1)
            offsets = (0 ..< columns).map { (CGFloat($0) * pitch).rounded() / scale }
        } else {
            let width = CGFloat(columns) * tile + CGFloat(columns - 1) * rowSpacing
            let start = ((size.width - width) * scale).rounded(.down) / scale
            offsets = (0 ..< columns).map { start + CGFloat($0) * (tile + rowSpacing) }
        }

        self.columns = columns
        self.weekRows = weekRows
        self.tileSize = tile
        self.cornerRadius = tile * Self.cornerRatio
        self.rowSpacing = rowSpacing
        self.weekRowSpacing = weekRowSpacing
        self.columnOffsets = offsets
        // Sit on the bottom edge, so the leftover height goes between the graph and whatever is above it.
        self.top = ((size.height - height(rowSpacing)) * scale).rounded(.down) / scale
    }

    // MARK: - Methods

    /// The frame of every day, grouped by level: `tiles[level]` holds the days with that level.
    func tiles(for calendar: ContributionCalendar) -> [[CGRect]] {
        var tiles = Array(repeating: [CGRect](), count: ContributionCalendar.maxLevel + 1)
        guard columns > 0, weekRows > 0 else { return tiles }
        let weekRowHeight = Self.days * tileSize + (Self.days - 1) * rowSpacing
        for (week, days) in calendar.weeks(columns * weekRows).enumerated() {
            let x = columnOffsets[week % columns]
            let weekRowTop = top + CGFloat(week / columns) * (weekRowHeight + weekRowSpacing)
            for (day, level) in days.enumerated() {
                guard let level else { continue }
                let y = weekRowTop + CGFloat(day) * (tileSize + rowSpacing)
                tiles[level].append(CGRect(x: x, y: y, width: tileSize, height: tileSize))
            }
        }
        return tiles
    }
}

// MARK: -

/// Rounded squares drawn as one shape, so each level is a single view however many days it has.
private struct TilesShape: Shape {
    let rects: [CGRect]
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        for tile in rects {
            path.addRoundedRect(in: tile.offsetBy(dx: rect.minX, dy: rect.minY), cornerSize: cornerSize, style: .continuous)
        }
        return path
    }
}
