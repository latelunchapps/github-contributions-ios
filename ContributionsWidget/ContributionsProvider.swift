//
//  ContributionsProvider.swift
//  ContributionsWidget
//
//  Created by Ander Goig on 19/10/2020.
//

import NetworkKit
import WidgetKit

struct ContributionsProvider: AppIntentTimelineProvider {
    // MARK: - Types

    typealias Entry = ContributionsViewModel

    // MARK: - Methods

    func placeholder(in context: Context) -> Entry {
        let contributions = lastYear().map { GitHub.Contribution(date: $0, level: .zero) }
        return Entry(contributions: contributions, configuration: WidgetIntentConfiguration(ConfigurationAppIntent()))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> Entry {
        let contributions = lastYear().map { GitHub.Contribution(date: $0, level: .random()) }
        return Entry(contributions: contributions, configuration: WidgetIntentConfiguration(configuration))
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<Entry> {
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: .now)!
        let configuration = WidgetIntentConfiguration(configuration)
        let username = configuration.username?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contributions = try? await GitHub.getContributions(for: username)
        return Timeline(entries: [Entry(contributions: contributions ?? [], configuration: configuration)], policy: .after(refreshDate))
    }

    // MARK: - Private Methods

    private func lastYear() -> [Date] {
        let currentDate = Date.now
        return Calendar.current.date(byAdding: .year, value: -1, to: currentDate)?.range(to: currentDate) ?? []
    }
}

// MARK: -

extension ContributionsViewModel: TimelineEntry {
    var date: Date {
        lastContributionDate ?? .now
    }
}
