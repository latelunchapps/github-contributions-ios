//
//  ConfigurationAppIntent.swift
//  ContributionsWidget
//

import AppIntents
import WidgetKit

/// The widget's configuration.
///
/// It replaces the SiriKit `ConfigurationIntent` that versions before 1.7 used, so widgets configured with it migrate.
/// `username` and `pureBlack` keep the SiriKit parameter names and types, which carries their values over.
/// `theme` keeps its name too, but the system doesn't carry enum values over (see `ThemeAppEnum`).
struct ConfigurationAppIntent: WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "ConfigurationIntent"

    static let title: LocalizedStringResource = "widget-configuration-title"
    static let description = IntentDescription("widget-configuration-description")

    /// A username saved in the app, or one typed in the configuration.
    @Parameter(title: "widget-configuration-username")
    var user: UsernameEntity?

    /// The username a widget was configured with through SiriKit.
    ///
    /// The system can't turn the SiriKit `String` into a `UsernameEntity`, so it migrates here instead.
    /// It is hidden from the configuration and only used until `user` is set.
    @Parameter(title: "widget-configuration-username")
    var username: String?

    @Parameter(title: "widget-configuration-theme", default: .green)
    var theme: ThemeAppEnum

    @Parameter(title: "widget-configuration-pure-black", default: false)
    var pureBlack: Bool

    /// The Lock Screen draws its widgets in a single system tint over the wallpaper, so neither the theme nor the
    /// background applies there and the configuration only offers the username.
    static var parameterSummary: some ParameterSummary {
        When(widgetFamily: .equalTo, .accessoryRectangular) {
            Summary {
                \.$user
            }
        } otherwise: {
            Summary {
                \.$user
                \.$theme
                \.$pureBlack
            }
        }
    }
}
