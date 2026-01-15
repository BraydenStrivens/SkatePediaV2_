//
//  TrickListViewByStance.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

/// A custom view containing a list of tricks for each stance in the user's trick list collection and the user's
/// progress in learning these tricks. This view requires a 'TrickListViewModel' object to be present in the
/// environment that is used to re-fetch the user's trick list after deleting or hiding a trick.
///
/// This view contains a custom progress bar showing the users progress for a given stance, and a list
/// of the tricks for a given stance they can click to navigate to the 'Trick View' for that trick. This
/// view also contains functionality for deleting and hiding tricks from the trick list. The base tricks initially
/// provided to the user at account creation cannot be deleted, only new tricks added by the user can.
///
/// - Parameters:
///  - trickList: 2D array of 'Trick' objects for a given stance that is sorted by difficulty.
///  - trickListInfo: A struct containing info about the user's trick list
///  - userId: The id of the current user.
///  - stance: The stance of the new trick.
///
struct trickListViewByStance: View {
    @EnvironmentObject var trickListViewModel: TrickListViewModel
    
    let trickList: [[Trick]]
    let trickListInfo: TrickListInfo
    let stance: String
    let userId: String
    
    @State private var showAddTrickView = false
    
    var body: some View {
        if !trickList.isEmpty{
            VStack {
                // Displays total tricks learned by stance
                TrickListInfoView(stance: stance, trickListInfo: trickListInfo)
                
                HStack(alignment: .center) {
                    // Trick list options menu
                    Menu {
                        Button("Reset Hidden Tricks") {
                            Task {
                                await trickListViewModel.resetHiddenTricks(userId: userId, stance: stance)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .tint(.primary)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Add trick button
                    Button {
                        showAddTrickView.toggle()
                    } label: {
                        Text("Add Trick")
                            .foregroundColor(.primary)
                        Image(systemName: "plus.square")
                            .tint(Color("buttonColor"))
                    }
                    .padding()
                }
                
                // Trick list separated by difficulty
                List {
                    Section("Easy") {
                        ForEach(trickList[0]) { easyTrick in
                            trickListCell(
                                userId: userId,
                                trick: easyTrick,
                                trickListInfo: trickListInfo
                            )
                        }
                    }
                    Section("Intermediate") {
                        ForEach(trickList[1]) { intermediateTrick in
                            trickListCell(
                                userId: userId,
                                trick: intermediateTrick,
                                trickListInfo: trickListInfo
                            )
                        }
                    }
                    Section("Advanced") {
                        ForEach(trickList[2]) { advancedTrick in
                            trickListCell(
                                userId: userId,
                                trick: advancedTrick,
                                trickListInfo: trickListInfo
                            )
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddTrickView, onDismiss: {
                showAddTrickView = false
            }, content: {
                AddTrickView(userId: userId, stance: stance, trickList: trickList, trickListInfo: trickListInfo)
                    .presentationDetents([.height(350)])
                    .environmentObject(trickListViewModel)
            })
        } else {
            ContentUnavailableView(
                "No Tricks Found",
                systemImage: "exclamationmark.triangle",
                description: Text("Failed to fetch \(stance) tricks...")
            )
        }
    }
    
    /// Custom view that displays information for a trick and a link to navigate to the "Trick View" for that trick.
    /// Displays the name of the trick and a symbol representing the user's progress in learning the trick if
    /// the user hasn't set it as hidden.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - trick: A struct containing information about a trick.
    ///  - trickListInfo: A struct containing info about the user's trick list
    ///
    /// - Returns: A view containing a trick's name, the user's progress, and navigation to a trick's 'Trick View'
    ///
    @ViewBuilder
    func trickListCell(userId: String, trick: Trick, trickListInfo: TrickListInfo) -> some View {
        if !trick.hidden {
            CustomNavLink(
                destination: TrickView(userId: userId, trick: trick)
                    .customNavBarItems(title: trick.name, subtitle: "", backButtonHidden: false)
                    .environmentObject(trickListViewModel)
            ) {
                HStack(alignment: .center, spacing: 12) {
                    Text(trick.name)
                        .foregroundColor(.primary)
                        .font(.callout)
                    
                    Spacer()
                    
                    // Displays a symbol representing the user's progress in learning the trick
                    if trick.progress.isEmpty {
                        Image(systemName: "circle")
                            .resizable()
                            .foregroundColor(.primary)
                            .frame(width: 20, height: 20)
                    } else {
                        let maxRating = trick.progress.max()!
                        
                        if maxRating == 0 {
                            Image(systemName: "circle")
                                .resizable()
                                .foregroundColor(Color("buttonColor"))
                                .frame(width: 20, height: 20)
                        } else if maxRating == 1 {
                            Image(systemName: "circle.circle")
                                .resizable()
                                .foregroundColor(Color("buttonColor"))
                                .frame(width: 20, height: 20)
                        } else if maxRating == 2 {
                            Image(systemName: "circle.circle.fill")
                                .resizable()
                                .foregroundColor(Color("buttonColor"))
                                .frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .foregroundColor(Color("AccentColor"))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                .contextMenu {
                    Button("Hide Trick From List") {
                        Task {
                            await trickListViewModel.hideTrick(userId: userId, trick: trick)
                        }
                    }
                    // The base tricks initially provided to the user have an id length of 8
                    // and aren't allowed to be deleted. User added tricks have a longer id
                    // length and are allowed to be deleted
                    if trick.id.count != 8 {
                        Button("Delete From List", role: .destructive) {
                            Task {
                                await trickListViewModel.deleteTrick(userId: userId, trick: trick)
                            }
                        }
                    }
                }
            }
        }
    }
}
