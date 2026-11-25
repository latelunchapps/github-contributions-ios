//
//  ContributionsGraphWidget.swift
//  ContributionsWidget
//
//  Created by Ander Goig on 19/10/2020.
//

import SwiftUI
import WidgetKit

struct ContributionsGraphWidget: Widget {
    // MARK: - Properties

    let kind: String = "ContributionsGraphWidget"

    // MARK: - View

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: ContributionsProvider()) { entry in
            ContributionsGraphEntryView(entry: entry)
        }
        .configurationDisplayName("widget-graph-display-name")
        .description("widget-graph-description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
