//
//  ContributionsGridLayout.swift
//  InterfaceKit
//

import CoreGraphics

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
