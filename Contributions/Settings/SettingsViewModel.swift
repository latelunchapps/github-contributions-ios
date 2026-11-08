//
//  SettingsViewModel.swift
//  Contributions
//
//  Created by Ander Goig on 20/10/2020.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var topItems: [SettingsItem] = [.widgetGuide]
    @Published private(set) var footerItems: [SettingsItem] = [.rate, .share, .feedback, .openSource]

    var rateURL: URL {
        URL(string: "itms-apps://apps.apple.com/app/id1537192731?action=write-review")!
    }

    var shareURL: URL {
        URL(string: "https://apps.apple.com/app/id1537192731")!
    }

    var feedbackURL: URL {
        URL(string: "mailto:support@latelunch.app")!
    }

    var openSourceURL: URL {
        URL(string: "https://github.com/latelunchapps/github-contributions-ios")!
    }
}
