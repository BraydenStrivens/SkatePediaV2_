//
//  TrickListInfoView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

struct trickListInfoView: View {
    
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
