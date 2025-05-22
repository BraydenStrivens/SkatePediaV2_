//
//  UserTrickListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

struct UserTrickListView: View {
    
    @ObservedObject var viewModel: AccountViewModel
    let user: User
    
    var body: some View {
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
                        .foregroundColor(.primary)
                    
                    // Regular stance tricks progress
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Regular:")
                                .foregroundColor(.gray)
                            Spacer()
                            CustomNavLink(
                                destination: TrickListPreviewView(userId: user.userId, stance: "Regular"),
                                label: {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            )
                        }
                        CustomProgressBar(
                            header: "",
                            totalTricks: trickListInfo.totalRegularTricks,
                            learnedTricks: trickListInfo.learnedRegularTricks,
                            width: UIScreen.screenWidth * 0.7
                        )
                    }
                    Divider()
                        .foregroundColor(.primary)
                    
                    // Fakie stance tricks progress
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Fakie:")
                                .foregroundColor(.gray)
                            Spacer()
                            CustomNavLink(
                                destination: TrickListPreviewView(userId: user.userId, stance: "Fakie"),
                                label: {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            )
                        }
                        CustomProgressBar(
                            header: "",
                            totalTricks: trickListInfo.totalFakieTricks,
                            learnedTricks: trickListInfo.learnedFakieTricks,
                            width: UIScreen.screenWidth * 0.7
                        )
                    }
                    Divider()
                        .foregroundColor(.primary)
                    
                    // Switch stance tricks progress
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Switch:")
                                .foregroundColor(.gray)
                            Spacer()
                            CustomNavLink(
                                destination: TrickListPreviewView(userId: user.userId, stance: "Switch"),
                                label: {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            )
                        }
                        CustomProgressBar(
                            header: "",
                            totalTricks: trickListInfo.totalSwitchTricks,
                            learnedTricks: trickListInfo.learnedSwitchTricks,
                            width: UIScreen.screenWidth * 0.7
                        )
                    }
                    Divider()
                        .foregroundColor(.primary)
                    
                    // Nollie stance tricks progress
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Nollie:")
                                .foregroundColor(.gray)
                            Spacer()
                            CustomNavLink(
                                destination: TrickListPreviewView(userId: user.userId, stance: "Nollie"),
                                label: {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            )
                        }
                        CustomProgressBar(
                            header: "",
                            totalTricks: trickListInfo.totalNollieTricks,
                            learnedTricks: trickListInfo.learnedNollieTricks,
                            width: UIScreen.screenWidth * 0.7
                        )
                    }
                }
            }
            .refreshable {
                Task {
                    try await viewModel.getTrickListInfo()
                }
            }
        } else {
            ProgressView()
        }
    }
}
