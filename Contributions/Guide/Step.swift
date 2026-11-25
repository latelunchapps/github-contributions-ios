//
//  Step.swift
//  Contributions
//
//  Created by Ander Goig on 24/10/2020.
//

import Foundation

enum Step: Int, CaseIterable {
    case one = 1, two, three, four, five, six, seven

    var title: String {
        .localizedStringWithFormat(NSLocalizedString("widget-guide-step-%u-title", comment: ""), rawValue)
    }

    var subtitle: String {
        NSLocalizedString("widget-guide-step-\(rawValue)-subtitle", comment: "")
    }

    var lightImageURL: URL? {
        assetsURL?.appendingPathComponent("widgets-step-\(rawValue).png")
    }

    var darkImageURL: URL? {
        assetsURL?.appendingPathComponent("widgets-step-dark-\(rawValue).png")
    }

    /// `HEAD` follows the repository's default branch. GitHub doesn't redirect raw file URLs
    /// when a branch is renamed, so naming a branch here breaks the images after a rename.
    /// Installed builds load these paths, so don't move or rename `.assets/v2`.
    private var assetsURL: URL? {
        URL(string: "https://raw.githubusercontent.com/latelunchapps/github-contributions-ios/HEAD/.assets/v2")
    }
}
