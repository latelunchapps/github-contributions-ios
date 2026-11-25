//
//  ContributionsRowViewModel.swift
//  Contributions
//
//  Created by Ander Goig on 24/10/2020.
//

import Foundation
import InterfaceKit
import NetworkKit

@MainActor
final class ContributionsRowViewModel: ObservableObject {
    // MARK: - Properties

    let username: String
    @Published private(set) var calendar: ContributionCalendar?

    var gitHubAccountURL: URL? {
        URL(string: "https://github.com/\(username)")
    }

    // MARK: - Init

    init(username: String) {
        self.username = username
    }

    // MARK: - Inputs

    @Sendable func loadContributions() async {
        guard calendar == nil else { return }
        let gitHubContributions = try? await GitHub.getContributions(for: username)
        calendar = gitHubContributions.flatMap(Self.calendar(from:))
    }

    // MARK: - Private Methods

    private static func calendar(from contributions: [GitHub.Contribution]) -> ContributionCalendar? {
        guard let lastDate = contributions.last?.date else { return nil }
        return ContributionCalendar(levels: contributions.map(\.level.rawValue), lastDate: lastDate)
    }
}
