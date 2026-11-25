//
//  ContributionsRow.swift
//  Contributions
//
//  Created by Ander Goig on 24/10/2020.
//

import InterfaceKit
import SwiftUI

struct ContributionsRow: View {
    // MARK: - Properties

    @Environment(\.openURL) var openURL
    @ObservedObject var viewModel: ContributionsRowViewModel

    // MARK: - View

    var body: some View {
        ContributionsView(
            calendar: viewModel.calendar,
            topLeadingText: viewModel.username,
            emptyText: NSLocalizedString("contributions-loading", comment: "")
        )
        .frame(height: 136)
        .padding(.vertical, 12)
        .onTapGesture(perform: onTap)
        .task(viewModel.loadContributions)
    }

    // MARK: - Private Methods

    private func onTap() {
        if let accountURL = viewModel.gitHubAccountURL {
            openURL(accountURL)
        }
    }
}
