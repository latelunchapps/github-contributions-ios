//
//  ContributionsGraphEntryView.swift
//  ContributionsWidget
//
//  Created by Ander Goig on 23/10/2020.
//

import InterfaceKit
import SwiftUI
import WidgetKit

struct ContributionsGraphEntryView: View {
    // MARK: - Properties

    @Environment(\.widgetFamily) var widgetFamily
    let entry: ContributionsViewModel

    // MARK: - View

    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            accessoryBody
                .containerBackground(for: .widget) { Color.clear }
        default:
            homeScreenBody
                .modifier(WidgetStyle(isPureBlackEnabled: entry.isPureBlackEnabled))
        }
    }

    /// The large widget is about as tall as it is wide, so it wraps the weeks into two rows to fill it.
    private var weekRows: Int {
        widgetFamily == .systemLarge ? 2 : 1
    }

    @ViewBuilder
    private var homeScreenBody: some View {
        if entry.showError {
            Text("contributions-fetch-error")
                .font(.callout)
                .multilineTextAlignment(.center)
        } else {
            ContributionsGraphWidgetView(viewModel: entry, weekRows: weekRows)
        }
    }

    /// The Lock Screen has no room for the header, so it shows the graph alone, a little denser.
    @ViewBuilder
    private var accessoryBody: some View {
        if let calendar = entry.calendar {
            ContributionsGrid(calendar: calendar, spacing: 0.2)
                .redacted(reason: entry.showPlaceholders ? .placeholder : .init())
        } else {
            Text(LocalizedStringKey(entry.showError ? "contributions-fetch-error" : "contributions-empty-text"))
                .font(.caption)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: -

struct WidgetStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let isPureBlackEnabled: Bool

    var backgroundColor: Color {
        colorScheme == .dark && isPureBlackEnabled ? .black : .backgroundSecondary
    }

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(for: .widget) {
                backgroundColor
            }
    }
}
