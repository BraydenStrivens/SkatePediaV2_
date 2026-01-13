//
//  UserTrickListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

///
/// Struct that displays information about a user's trick list.
///
struct UserTrickListView: View {
    
    @EnvironmentObject var viewModel: UserAccountViewModel
    let user: User
    
    var body: some View {
        // Verifies the trick list data was fetched.
        if let trickListInfo = viewModel.userTrickListInfo {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    
                    // Total trick progress
                    VStack(alignment: .leading) {
                        Text("Total:")
                            .foregroundColor(.gray)
                        
                        CustomProgressBar(
                            header: "",
                            totalTricks: trickListInfo.totalTricks,
                            learnedTricks: trickListInfo.learnedTricks,
                            width: UIScreen.screenWidth * 0.65
                        )
                    }
                    
                    Divider()
                    
                    ForEach(Stance.Stances.allCases) { stance in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(stance.rawValue)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                CustomNavLink(
                                    destination: TrickListPreviewView(userId: user.userId, stance: stance.rawValue),
                                    label: {
                                        Image(systemName: "ellipsis")
                                            .foregroundColor(.gray)
                                    }
                                )
                            }
                            
                            switch stance {
                            case Stance.Stances.regular:
                                CustomProgressBar(
                                    header: "",
                                    totalTricks: trickListInfo.totalRegularTricks,
                                    learnedTricks: trickListInfo.learnedRegularTricks,
                                    width: UIScreen.screenWidth * 0.7
                                )
                            case Stance.Stances.fakie:
                                CustomProgressBar(
                                    header: "",
                                    totalTricks: trickListInfo.totalFakieTricks,
                                    learnedTricks: trickListInfo.learnedFakieTricks,
                                    width: UIScreen.screenWidth * 0.7
                                )
                            case Stance.Stances._switch:
                                CustomProgressBar(
                                    header: "",
                                    totalTricks: trickListInfo.totalSwitchTricks,
                                    learnedTricks: trickListInfo.learnedSwitchTricks,
                                    width: UIScreen.screenWidth * 0.7
                                )
                            case Stance.Stances.nollie:
                                CustomProgressBar(
                                    header: "",
                                    totalTricks: trickListInfo.totalNollieTricks,
                                    learnedTricks: trickListInfo.learnedNollieTricks,
                                    width: UIScreen.screenWidth * 0.7
                                )
                            }
                        }
                        
                        Divider()
                    }
                }
            }
            .refreshable {
                Task {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    await viewModel.getTrickListInfo(userId: user.userId)
                }
            }
        } else {
            ProgressView()
        }
    }
}
