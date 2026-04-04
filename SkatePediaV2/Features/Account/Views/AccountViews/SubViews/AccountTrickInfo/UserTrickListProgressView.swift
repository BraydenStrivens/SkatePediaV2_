//
//  UserTrickListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

/// View displaying a user's trick list progress.
///
/// Shows overall progress and stance-specific breakdowns,
/// with navigation to detailed trick lists for each stance.
///
/// - Parameters:
///   - user: The user whose trick data is being displayed.
///   - trickListData: Aggregated trick progress data for the user.
struct UserTrickListProgressView: View {
    @EnvironmentObject private var router: AccountRouter
    @Environment(\.colorScheme) private var colorScheme
    
    let user: User
    let trickListData: TrickListData
    
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
                            Button {
                                router.push(.userTricks(stance))
                            } label: {
                                CustomProgressBar(
                                    showHeader: false,
                                    totalTricks: trickListData.regularTotal,
                                    learnedTricks: trickListData.regularLearned,
                                    width: progressBarWidth
                                )
                            }
                            
                        case .fakie:
                            Button {
                                router.push(.userTricks(stance))
                            } label: {
                                CustomProgressBar(
                                    showHeader: false,
                                    totalTricks: trickListData.fakieTotal,
                                    learnedTricks: trickListData.fakieLearned,
                                    width: progressBarWidth
                                )
                            }
                            
                        case ._switch:
                            Button {
                                router.push(.userTricks(stance))
                            } label: {
                                CustomProgressBar(
                                    showHeader: false,
                                    totalTricks: trickListData.switchTotal,
                                    learnedTricks: trickListData.switchLearned,
                                    width: progressBarWidth
                                )
                            }
                            
                        case .nollie:
                            Button {
                                router.push(.userTricks(stance))
                            } label: {
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
