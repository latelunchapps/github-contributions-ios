//
//  ConfigurationAppIntent.swift
//  ContributionsWidget
//

import AppIntents
import WidgetKit

/// The widget's configuration from iOS 17 on. Earlier versions use the SiriKit `ConfigurationIntent`.
///
/// It replaces `ConfigurationIntent`. `username` and `pureBlack` keep the names and types they have in
/// `GitHubContributionsWidget.intentdefinition`, which carries their values over when a widget migrates.
/// `theme` keeps its name too, but the system doesn't carry enum values over (see `ThemeAppEnum`).
@available(iOS 17.0, *)
struct ConfigurationAppIntent: WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ConfigurationIntent"

    static let title: LocalizedStringResource = "widget-configuration-title"
    static let description = IntentDescription("widget-configuration-description")

    /// A username saved in the app, or one typed in the configuration.
    @Parameter(title: "widget-configuration-username")
    var user: UsernameEntity?

    /// The username a widget was configured with before iOS 17.
    ///
    /// The system can't turn the SiriKit `String` into a `UsernameEntity`, so it migrates here instead.
    /// It is hidden from the configuration and only used until `user` is set.
    @Parameter(title: "widget-configuration-username")
    var username: String?

    @Parameter(title: "widget-configuration-theme", default: .green)
    var theme: ThemeAppEnum

    @Parameter(title: "widget-configuration-pure-black", default: false)
    var pureBlack: Bool

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$user
            \.$theme
            \.$pureBlack
        }
    }
}
