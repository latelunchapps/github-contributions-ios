//
//  ContributionsTheme.swift
//  InterfaceKit
//

import SwiftUI

/// The colors of a contribution graph.
///
/// Each theme is a single-hue ramp defined for light and dark appearances in `Colors.xcassets`. In light mode the
/// steps run from light to dark, starting with a pale tint like GitHub's; in dark mode they run from dim to bright
/// in even steps. Either way, more contributions always stand out more from the background. Days without
/// contributions share one neutral gray.
public enum ContributionsTheme: CaseIterable, Sendable {
    case green
    case blue
    case red
    case purple
    case yellow
    case inverted

    // MARK: - Methods

    /// The full-color fill of a day with `level` contributions, from 0 to `ContributionCalendar.maxLevel`.
    public func color(forLevel level: Int) -> Color {
        guard level > 0 else { return Color(.Tile.empty) }
        return Color(levelColors[min(level, levelColors.count) - 1])
    }

    // MARK: - Private

    private var levelColors: [ColorResource] {
        switch self {
        case .green: [.Green.level1, .Green.level2, .Green.level3, .Green.level4]
        case .blue: [.Blue.level1, .Blue.level2, .Blue.level3, .Blue.level4]
        case .red: [.Red.level1, .Red.level2, .Red.level3, .Red.level4]
        case .purple: [.Purple.level1, .Purple.level2, .Purple.level3, .Purple.level4]
        case .yellow: [.Yellow.level1, .Yellow.level2, .Yellow.level3, .Yellow.level4]
        case .inverted: [.Inverted.level1, .Inverted.level2, .Inverted.level3, .Inverted.level4]
        }
    }
}
