//
//  UserTrickListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

/// Struct that displays information about a user's trick list.
///
struct UserTrickListView: View {
//    @EnvironmentObject private var currentUserViewVM: CurrentUserAccountViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    let user: User
    let trickListData: TrickListData
//    var trickListData: TrickListData {
//        currentUserViewVM.user.trickListData
//    }
    
    init(user: User) {
        self.user = user
        self.trickListData = user.trickListData
    }
    
    private let progressBarWidth: CGFloat = UIScreen.screenWidth * 0.6
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading) {
                Text("Total:")
                    .font(.caption)
                    .foregroundColor(.gray)

                CustomProgressBar(
                    showHeader: false,
                    totalTricks: trickListData.total,
                    learnedTricks: trickListData.totalLearned,
                    width: progressBarWidth
                )
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
            }
                        
            ForEach(TrickStance.allCases) { stance in
                VStack(alignment: .leading) {
                    HStack {
                        Text(stance.camalCase)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    
                    Group {
                        switch stance {
                        case .regular:
                            NavigationLink(
                                destination: TrickListPreviewView(
                                    userId: user.userId,
                                    stance: stance
                                )
                                .customNavHeader(
                                    title: "\(user.username)'s \(stance.camalCase) Tricks",
                                    showDivider: true
                                )
                            ) {
                                CustomProgressBar(
                                    showHeader: false,
                                    totalTricks: trickListData.regularTotal,
                                    learnedTricks: trickListData.regularLearned,
                                    width: progressBarWidth
                                )
                            }
                            
                        case .fakie:
                            NavigationLink(
                                destination: TrickListPreviewView(
                                    userId: user.userId,
                                    stance: stance
                                )
                                .customNavHeader(
                                    title: "\(user.username)'s \(stance.camalCase) Tricks",
                                    showDivider: true
                                )
                            ) {
                                CustomProgressBar(
                                    showHeader: false,
                                    totalTricks: trickListData.fakieTotal,
                                    learnedTricks: trickListData.fakieLearned,
                                    width: progressBarWidth
                                )
                            }
                            
                            
                        case ._switch:
                            NavigationLink(
                                destination: TrickListPreviewView(
                                    userId: user.userId,
                                    stance: stance
                                )
                                .customNavHeader(
                                    title: "\(user.username)'s \(stance.camalCase) Tricks",
                                    showDivider: true
                                )
                            ) {
                                CustomProgressBar(
                                    showHeader: false,
                                    totalTricks: trickListData.switchTotal,
                                    learnedTricks: trickListData.switchLearned,
                                    width: progressBarWidth
                                )
                            }
                            
                        case .nollie:
                            NavigationLink(
                                destination: TrickListPreviewView(
                                    userId: user.userId,
                                    stance: stance
                                )
                                .customNavHeader(
                                    title: "\(user.username)'s \(stance.camalCase) Tricks",
                                    showDivider: true
                                )
                            ) {
                                CustomProgressBar(
                                    showHeader: false,
                                    totalTricks: trickListData.nollieTotal,
                                    learnedTricks: trickListData.nollieLearned,
                                    width: progressBarWidth
                                )
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
                    .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
                }
            }
            Spacer()
        }
    }
}
