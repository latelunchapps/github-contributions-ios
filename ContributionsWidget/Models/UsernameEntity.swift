//
//  UsernameEntity.swift
//  ContributionsWidget
//

import AppIntents

/// A GitHub username, either one saved in the app or one typed in the widget's configuration.
struct UsernameEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "widget-configuration-username"
    static let defaultQuery = UsernameQuery()

    let id: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }
}

// MARK: -

struct UsernameQuery: EntityStringQuery {
    /// Any username resolves, saved or not, so a typed username, or one later removed from the app, keeps working.
    func entities(for identifiers: [UsernameEntity.ID]) async throws -> [UsernameEntity] {
        identifiers.map(UsernameEntity.init(id:))
    }

    /// The saved usernames that contain `string`, led by `string` itself unless it is one of them.
    func entities(matching string: String) async throws -> [UsernameEntity] {
        let query = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedUsernames = await DefaultContributionsStorage().usernames
        guard !query.isEmpty else { return savedUsernames.map(UsernameEntity.init(id:)) }
        let matches = savedUsernames.filter { $0.localizedCaseInsensitiveContains(query) }
        let isSaved = matches.contains { $0.caseInsensitiveCompare(query) == .orderedSame }
        return (isSaved ? matches : [query] + matches).map(UsernameEntity.init(id:))
    }

    /// The usernames saved in the app.
    func suggestedEntities() async throws -> [UsernameEntity] {
        await DefaultContributionsStorage().usernames.map(UsernameEntity.init(id:))
    }
}
