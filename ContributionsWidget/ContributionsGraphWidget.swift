//
//  ContributionsGraphWidget.swift
//  ContributionsWidget
//
//  Created by Ander Goig on 19/10/2020.
//

import Intents
import SwiftUI
import WidgetKit

/// The graph widget before iOS 17, configured with the SiriKit `ConfigurationIntent`.
struct ContributionsGraphWidget: Widget {
    // MARK: - Properties

    static let kind: String = "ContributionsGraphWidget"

    // MARK: - View

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: Self.kind, intent: ConfigurationIntent.self, provider: ContributionsProvider()) { entry in
            ContributionsGraphEntryView(entry: entry)
        }
        .contributionsGraph()
    }
}

// MARK: -

/// The graph widget from iOS 17 on, configured with `ConfigurationAppIntent`.
///
/// It shares `ContributionsGraphWidget.kind`, so widgets already on the Home Screen move to it.
@available(iOSApplicationExtension 17.0, *)
struct ContributionsGraphAppIntentWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: ContributionsGraphWidget.kind, intent: ConfigurationAppIntent.self, provider: ContributionsAppIntentProvider()) { entry in
            ContributionsGraphEntryView(entry: entry)
        }
        .contributionsGraph()
    }
}

// MARK: -

private extension WidgetConfiguration {
    func contributionsGraph() -> some WidgetConfiguration {
        configurationDisplayName("widget-graph-display-name")
            .description("widget-graph-description")
            .supportedFamilies([.systemSmall, .systemMedium])
            .contentMarginsDisabled()
    }
}
