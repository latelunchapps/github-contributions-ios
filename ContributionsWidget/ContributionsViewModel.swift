//
//  ContributionsViewModel.swift
//  ContributionsWidget
//
//  Created by Ander Goig on 23/10/2020.
//

import Foundation
import InterfaceKit
import NetworkKit

@dynamicMemberLookup
struct ContributionsViewModel {
    // MARK: - Properties

    private let contributions: [GitHub.Contribution]
    private let configuration: WidgetIntentConfiguration

    // MARK: - Outputs

    subscript<T>(dynamicMember keyPath: KeyPath<WidgetIntentConfiguration, T>) -> T {
        configuration[keyPath: keyPath]
    }

    var showPlaceholders: Bool {
        contributions.isEmpty
    }

    var topLeadingText: String? {
        configuration.username
    }

    var showError: Bool {
        configuration.username != .none && contributions.isEmpty
    }

    var lastContributionDate: Date? {
        contributions.last?.date
    }

    /// Every fetched day, for the graph to show as many weeks as fit.
    var calendar: ContributionCalendar? {
        guard let lastDate = lastContributionDate else { return nil }
        return ContributionCalendar(levels: contributions.map(\.level.rawValue), lastDate: lastDate)
    }

    // MARK: - Init

    init(contributions: [GitHub.Contribution], configuration: WidgetIntentConfiguration) {
        self.contributions = contributions
        self.configuration = configuration
    }
}
