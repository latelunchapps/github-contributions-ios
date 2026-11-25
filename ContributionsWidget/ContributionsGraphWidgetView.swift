//
//  ContributionsGraphWidgetView.swift
//  ContributionsWidget
//
//  Created by Ander Goig on 23/10/2020.
//

import InterfaceKit
import SwiftUI

struct ContributionsGraphWidgetView: View {
    // MARK: - Properties

    let viewModel: ContributionsViewModel
    let weekRows: Int

    // MARK: - View

    var body: some View {
        ContributionsView(
            calendar: viewModel.calendar,
            theme: viewModel.theme,
            weekRows: weekRows,
            topLeadingText: viewModel.topLeadingText,
            emptyText: NSLocalizedString("contributions-empty-text", comment: "")
        )
        .redacted(reason: viewModel.showPlaceholders ? .placeholder : .init())
    }
}
