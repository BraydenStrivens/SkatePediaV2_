//
//  PrivacyPolicyView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

/// A placeholder view for the Privacy Policy screen.
///
/// Currently displays a message that the content is unavailable.
/// Intended to be replaced with the actual privacy policy content in the future.
struct PrivacyPolicyView: View {
    var body: some View {
        ContentUnavailableView(
            "Currently Unavailable",
            systemImage: "exclamationmark.triangle"
        )
        .customNavHeader(
            title: "Privacy Policy",
            showDivider: true
        )
    }
}
