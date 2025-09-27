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
    
    @ObservedObject var viewModel: AccountViewModel
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
                    
                    // Regular stance progress
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
                    
                    // Fakie stance progress
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
                    
                    // Switch stance progress
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
