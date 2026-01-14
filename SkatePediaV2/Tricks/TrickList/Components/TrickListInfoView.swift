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
    let stance: String
    let trickListInfo: TrickListInfo?
    
    var body: some View {
        if let trickListInfo = trickListInfo {
            switch(stance) {
            case "Regular":
                CustomProgressBar(
                    header: stance,
                    totalTricks: trickListInfo.totalRegularTricks,
                    learnedTricks: trickListInfo.learnedRegularTricks
                )
            case "Fakie":
                CustomProgressBar(
                    header: stance,
                    totalTricks: trickListInfo.totalFakieTricks,
                    learnedTricks: trickListInfo.learnedFakieTricks
                )
            case "Switch":
                CustomProgressBar(
                    header: stance,
                    totalTricks: trickListInfo.totalSwitchTricks,
                    learnedTricks: trickListInfo.learnedSwitchTricks
                )
            case "Nollie":
                CustomProgressBar(
                    header: stance,
                    totalTricks: trickListInfo.totalNollieTricks,
                    learnedTricks: trickListInfo.learnedNollieTricks
                )
            default:
                CustomProgressBar(
                    header: "Total",
                    totalTricks: trickListInfo.totalTricks,
                    learnedTricks: trickListInfo.learnedTricks
                )
            }
        }
    }
}
