//
//  ContributionsView.swift
//  InterfaceKit
//
//  Created by Ander Goig on 19/10/2020.
//

import SwiftUI

/// A contribution graph under a GitHub header, filling the space it is given.
public struct ContributionsView: View {
    // MARK: - Properties

    let calendar: ContributionCalendar?
    let theme: ContributionsTheme
    let weekRows: Int
    let topLeadingText: String?
    let topTrailingText: String?
    let emptyText: String?

    /// The GitHub mark's size, scaled with the caption it sits next to.
    @ScaledMetric(relativeTo: .caption2)
    private var markSize = 12.0

    // MARK: - View

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Image(.gitHubMark)
                        .resizable()
                        .frame(width: markSize, height: markSize)
                        .unredacted()
                        .accessibilityHidden(true)

                    topLeadingText.map(Text.init)
                }

                Spacer()

                topTrailingText.map(Text.init)
            }
            .captionStyle()

            if let calendar {
                ContributionsGrid(calendar: calendar, theme: theme, weekRows: weekRows)
                    .padding(.top, 8)
            } else {
                Spacer()

                Label(emptyText ?? "", systemImage: "info.circle")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .unredacted()

                Spacer()
            }
        }
    }

    // MARK: - Init

    /// Creates a graph of `calendar` wrapped into `weekRows` rows of weeks, or shows `emptyText` when there is no calendar.
    public init(
        calendar: ContributionCalendar?,
        theme: ContributionsTheme = .green,
        weekRows: Int = 1,
        topLeadingText: String? = nil,
        topTrailingText: String? = nil,
        emptyText: String? = nil
    ) {
        self.calendar = calendar
        self.theme = theme
        self.weekRows = weekRows
        self.topLeadingText = topLeadingText
        self.topTrailingText = topTrailingText
        self.emptyText = emptyText
    }
}
