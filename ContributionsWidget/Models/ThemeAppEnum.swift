//
//  ThemeAppEnum.swift
//  ContributionsWidget
//

import AppIntents

/// The widget's theme in its App Intents configuration.
///
/// The system doesn't carry SiriKit enum values over to an `AppEnum`,
/// so widgets configured in versions before 1.7 start on the default theme after they migrate.
enum ThemeAppEnum: String, AppEnum {
    case green
    case blue
    case red
    case purple
    case yellow
    case inverted

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "widget-configuration-theme"

    static let caseDisplayRepresentations: [ThemeAppEnum: DisplayRepresentation] = [
        .green: "widget-configuration-theme-green",
        .blue: "widget-configuration-theme-blue",
        .red: "widget-configuration-theme-red",
        .purple: "widget-configuration-theme-purple",
        .yellow: "widget-configuration-theme-yellow",
        .inverted: "widget-configuration-theme-inverted",
    ]
}
