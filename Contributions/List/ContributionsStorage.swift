//
//  ContributionsStorage.swift
//  Contributions
//
//  Created by Ander Goig on 10/8/24.
//

import Foundation

protocol ContributionsStorage: Actor {
    var usernames: [String] { get }
    func setUsernames(_ usernames: [String])
}

// MARK: -

actor DefaultContributionsStorage: ContributionsStorage {
    private static let usernamesKey = "usernames"
    private let userDefaults: UserDefaults

    /// - Parameters:
    ///   - userDefaults: Where the usernames are kept. The default is the App Group suite, which the app and the widget share.
    ///   - legacyUserDefaults: Where an earlier version kept them. If `userDefaults` has none yet, they are copied from here once.
    init(userDefaults: UserDefaults = .appGroup, migratingFrom legacyUserDefaults: UserDefaults? = nil) {
        if let legacyUserDefaults, legacyUserDefaults !== userDefaults,
           userDefaults.object(forKey: Self.usernamesKey) == nil,
           let data = legacyUserDefaults.data(forKey: Self.usernamesKey) {
            userDefaults.set(data, forKey: Self.usernamesKey)
        }
        self.userDefaults = userDefaults
    }

    var usernames: [String] {
        userDefaults.codable(forKey: Self.usernamesKey) ?? []
    }

    func setUsernames(_ usernames: [String]) {
        userDefaults.set(value: usernames, forKey: Self.usernamesKey)
    }
}
