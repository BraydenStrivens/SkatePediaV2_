//
//  TermsOfServiceView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

/// A placeholder view for the Terms of Service screen.
///
/// Currently displays a message that the content is unavailable.
/// Intended to be replaced with the actual terms content in the future.
struct TermsOfServiceView: View {
    var body: some View {
        ContentUnavailableView(
            "Currently Unavailable",
            systemImage: "exclamationmark.triangle"
        )
        .customNavHeader(
            title: "Terms of Service",
            showDivider: true
        )
    }
}
