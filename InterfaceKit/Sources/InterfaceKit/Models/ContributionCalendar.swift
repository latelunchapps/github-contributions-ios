//
//  ContributionCalendar.swift
//  InterfaceKit
//

import Foundation

/// Daily contribution levels laid out as calendar weeks, the way GitHub draws them.
///
/// Each week is a column that runs from Sunday to Saturday, and the last column is the current week.
public struct ContributionCalendar: Equatable, Sendable {
    // MARK: - Properties

    /// The number of days in a week, and so the number of rows in the graph.
    public static let daysPerWeek = 7

    /// The highest level a day can have.
    public static let maxLevel = 4

    /// One level per day, oldest first, from 0 (no contributions) to `maxLevel`.
    public let levels: [Int]

    /// The weekday of the last day, from 1 (Sunday) to 7 (Saturday).
    public let lastWeekday: Int

    /// The number of weeks the days span, counting partial weeks at either end.
    public var weekCount: Int {
        let trailingGap = Self.daysPerWeek - lastWeekday
        return (levels.count + trailingGap + Self.daysPerWeek - 1) / Self.daysPerWeek
    }

    // MARK: - Init

    /// Creates a calendar from daily levels, oldest first, whose last day has the weekday `lastWeekday`.
    public init(levels: [Int], lastWeekday: Int) {
        self.levels = levels.map { min(max($0, 0), Self.maxLevel) }
        self.lastWeekday = min(max(lastWeekday, 1), Self.daysPerWeek)
    }

    /// Creates a calendar from daily levels, oldest first, whose last day is `lastDate`.
    public init(levels: [Int], lastDate: Date, calendar: Calendar = .current) {
        self.init(levels: levels, lastWeekday: calendar.component(.weekday, from: lastDate))
    }

    // MARK: - Methods

    /// The level of each day in the last `count` weeks, one array of seven per week, oldest week first.
    ///
    /// Days after the last day, and days before the first one, are `nil`.
    public func weeks(_ count: Int) -> [[Int?]] {
        guard count > 0 else { return [] }
        let trailingGap = Self.daysPerWeek - lastWeekday
        let slots = count * Self.daysPerWeek
        let lastIndex = levels.count - 1
        return (0 ..< count).map { week in
            (0 ..< Self.daysPerWeek).map { day in
                // Distance from the last slot of the grid, then from the last day.
                let fromEnd = slots - 1 - (week * Self.daysPerWeek + day) - trailingGap
                guard fromEnd >= 0 else { return nil }
                let index = lastIndex - fromEnd
                return index >= 0 ? levels[index] : nil
            }
        }
    }
}
