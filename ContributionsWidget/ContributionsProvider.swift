//
//  ContributionsProvider.swift
//  ContributionsWidget
//
//  Created by Ander Goig on 19/10/2020.
//

import NetworkKit
import WidgetKit

final class ContributionsProvider: IntentTimelineProvider {
    // MARK: - Types

    public typealias Entry = ContributionsViewModel

    // MARK: - Properties

    private var timelineTask: Task<Void, Error>?

    // MARK: - Methods

    func placeholder(in context: Context) -> Entry {
        .placeholder(configuration: WidgetIntentConfiguration(ConfigurationIntent()))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> Void) {
        completion(.snapshot(configuration: WidgetIntentConfiguration(configuration)))
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping @Sendable (Timeline<Entry>) -> Void) {
        let configuration = WidgetIntentConfiguration(configuration)
        timelineTask = Task {
            completion(await Entry.timeline(configuration: configuration))
        }
    }
}

// MARK: -

@available(iOSApplicationExtension 17.0, *)
struct ContributionsAppIntentProvider: AppIntentTimelineProvider {
    typealias Entry = ContributionsViewModel

    func placeholder(in context: Context) -> Entry {
        .placeholder(configuration: WidgetIntentConfiguration(ConfigurationAppIntent()))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> Entry {
        .snapshot(configuration: WidgetIntentConfiguration(configuration))
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<Entry> {
        await Entry.timeline(configuration: WidgetIntentConfiguration(configuration))
    }
}

// MARK: -

extension ContributionsViewModel: TimelineEntry {
    var date: Date {
        lastContributionDate ?? .now
    }
}

// MARK: -

extension ContributionsViewModel {
    /// A year of empty contributions.
    static func placeholder(configuration: WidgetIntentConfiguration) -> Self {
        Self(contributions: lastYear().map { GitHub.Contribution(date: $0, level: .zero) }, configuration: configuration)
    }

    /// A year of random contributions.
    static func snapshot(configuration: WidgetIntentConfiguration) -> Self {
        Self(contributions: lastYear().map { GitHub.Contribution(date: $0, level: .random()) }, configuration: configuration)
    }

    /// The configured user's contributions, refreshed after five minutes.
    static func timeline(configuration: WidgetIntentConfiguration) async -> Timeline<Self> {
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: .now)!
        let username = configuration.username?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contributions = try? await GitHub.getContributions(for: username)
        return Timeline(entries: [Self(contributions: contributions ?? [], configuration: configuration)], policy: .after(refreshDate))
    }

    private static func lastYear() -> [Date] {
        let currentDate = Date.now
        return Calendar.current.date(byAdding: .year, value: -1, to: currentDate)?.range(to: currentDate) ?? []
    }
}
