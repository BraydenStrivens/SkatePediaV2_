//
//  TrickListInfoView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

/// A view that displays a progress bar representing the user's trick learning progress.
///
/// Shows progress either globally (all stances) or filtered by a specific stance.
/// The view renders a `CustomProgressBar` configured with the appropriate total and learned counts
/// based on the selected stance.
///
/// If no stance is provided, it displays overall progress across all tricks.
///
/// - Important:
///   Requires `UserStore` to provide `trickListData`.
struct TrickListInfoView: View {
    @EnvironmentObject var userStore: UserStore
    
    /// Optional stance used to filter progress data.
    /// If `nil`, overall progress is displayed.
    let stance: TrickStance?
    
    var body: some View {
        if let trickListData = userStore.trickListData {
            switch(stance) {
            case .regular:
                CustomProgressBar(
                    stance: stance,
                    totalTricks: trickListData.regularTotal,
                    learnedTricks: trickListData.regularLearned
                )
            case .fakie:
                CustomProgressBar(
                    stance: stance,
                    totalTricks: trickListData.fakieTotal,
                    learnedTricks: trickListData.fakieLearned
                )
            case ._switch:
                CustomProgressBar(
                    stance: stance,
                    totalTricks: trickListData.switchTotal,
                    learnedTricks: trickListData.switchLearned
                )
            case .nollie:
                CustomProgressBar(
                    stance: stance,
                    totalTricks: trickListData.nollieTotal,
                    learnedTricks: trickListData.nollieLearned
                )
            case nil:
                CustomProgressBar(
                    stance: nil,
                    totalTricks: trickListData.total,
                    learnedTricks: trickListData.totalLearned
                )
            }
        }
    }
}
