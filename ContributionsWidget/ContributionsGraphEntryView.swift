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
        homeScreenBody
            .modifier(WidgetStyle(isPureBlackEnabled: entry.isPureBlackEnabled))
    }

    @ViewBuilder
    private var homeScreenBody: some View {
        if entry.showError {
            Text("contributions-fetch-error")
                .font(.callout)
                .multilineTextAlignment(.center)
        } else {
            ContributionsGraphWidgetView(viewModel: entry, weekRows: 1)
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
