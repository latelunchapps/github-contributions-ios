//
//  WidgetIntentConfiguration.swift
//  Contributions
//
//  Created by Ander Goig on 14/8/25.
//

import Foundation
import InterfaceKit

struct WidgetIntentConfiguration: Sendable {
    let username: String?
    let theme: ContributionsTheme
    let isPureBlackEnabled: Bool

    init(_ intent: ConfigurationAppIntent) {
        self.username = intent.user?.id ?? intent.username
        self.theme = ContributionsTheme(intent.theme)
        self.isPureBlackEnabled = intent.pureBlack
    }
}

// MARK: -

private extension ContributionsTheme {
    init(_ theme: ThemeAppEnum) {
        switch theme {
        case .green: self = .green
        case .blue: self = .blue
        case .red: self = .red
        case .purple: self = .purple
        case .yellow: self = .yellow
        case .inverted: self = .inverted
        }
    }
}
