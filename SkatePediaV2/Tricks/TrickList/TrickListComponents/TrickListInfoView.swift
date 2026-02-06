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
///
/// - Parameters:
///  - stance: The stance of the trick list for which the user's progress is being displayed.
///  - trickListInfo: A struct containing data about the user's trick progress.
///
struct TrickListInfoView: View {
    @EnvironmentObject var trickListVM: TrickListViewModel
    let stance: TrickStance?
    
    init(stance: TrickStance? = nil) {
        self.stance = stance
    }
    
    var body: some View {
        if let stance = stance {
            switch(stance) {
            case TrickStance.regular:
                CustomProgressBar(
                    header: stance.camalCase,
                    totalTricks: trickListVM.trickListData.regularTotal,
                    learnedTricks: trickListVM.trickListData.regularLearned
                )
            case TrickStance.fakie:
                CustomProgressBar(
                    header: stance.camalCase,
                    totalTricks: trickListVM.trickListData.fakieTotal,
                    learnedTricks: trickListVM.trickListData.fakieLearned
                )
            case TrickStance._switch:
                CustomProgressBar(
                    header: stance.camalCase,
                    totalTricks: trickListVM.trickListData.switchTotal,
                    learnedTricks: trickListVM.trickListData.switchLearned
                )
            case TrickStance.nollie:
                CustomProgressBar(
                    header: stance.camalCase,
                    totalTricks: trickListVM.trickListData.nollieTotal,
                    learnedTricks: trickListVM.trickListData.nollieLearned
                )
            }
        } else {
            CustomProgressBar(
                header: "Total",
                totalTricks: trickListVM.trickListData.total,
                learnedTricks: trickListVM.trickListData.totalLearned
            )
        }
    }
}
