//
//  TrickListInfoView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

/// A custom view that displays a custom progress bar showing the user's progress in learning all tricks and each
/// stance's tricks. The custom progress bar contains a header indicating the stance it is for, a visual bar showing the
/// percentage of tricks learned, and a fraction showing the number of tricks learned out of the total number of tricks.
struct TrickListInfoView: View {
    @EnvironmentObject var userStore: UserStore
    
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
