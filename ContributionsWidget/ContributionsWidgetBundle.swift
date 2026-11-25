//
//  ContributionsWidgetBundle.swift
//  ContributionsWidget
//
//  Created by Ander Goig on 14/10/2020.
//

import SwiftUI
import WidgetKit

/// Starts the bundle for the running iOS version.
///
/// A `WidgetBundleBuilder` takes `if #available` but no `else`,
/// so the choice between the App Intents and the SiriKit widget is made here instead.
@main
enum ContributionsWidgetLauncher {
    @MainActor static func main() {
        if #available(iOSApplicationExtension 17.0, *) {
            ContributionsWidgetBundle.main()
        } else {
            LegacyContributionsWidgetBundle.main()
        }
    }
}

// MARK: -

/// The widgets from iOS 17 on, configured with App Intents.
@available(iOSApplicationExtension 17.0, *)
struct ContributionsWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ContributionsGraphAppIntentWidget()
    }
}

// MARK: -

/// The widgets before iOS 17, configured with SiriKit intents.
struct LegacyContributionsWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ContributionsGraphWidget()
    }
}
