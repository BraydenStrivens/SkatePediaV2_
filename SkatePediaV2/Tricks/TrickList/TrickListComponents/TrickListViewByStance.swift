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
struct TrickListViewByStance: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddTrickView = false
    
    @ObservedObject var trickListVM: TrickListViewModel
    let stance: TrickStance
    var tricks: [Trick] {
        trickListVM.tricks(for: stance)
    }
    
    var body: some View {
        Group {
            if tricks.isEmpty {
                ContentUnavailableView(
                    "No Tricks Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Failed to fetch \(stance.camalCase) tricks...")
                )
                
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            // Displays total tricks learned by stance
                            TrickListInfoView(stance: stance)
                                .environmentObject(trickListVM)
                            
                            HStack(alignment: .center) {
                                // Trick list options menu
                                Menu {
                                    Button("Reset Hidden Tricks") {
                                        Task {
                                            await trickListVM.resetHiddenTricks(for: stance)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .tint(.primary)
                                        .padding(.horizontal)
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
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                        
                        ForEach(TrickDifficulty.allCases) { difficulty in
                            DifficultyCard(
                                trickListVM: trickListVM,
                                difficulty: difficulty,
                                stance: stance
                            )
                        }
                    }
                    .padding(.bottom)
                }
                .scrollIndicators(.hidden)
            }
        }
        .sheet(isPresented: $showAddTrickView, onDismiss: {
            showAddTrickView = false
        }, content: {
            AddTrickView(
                stance: stance,
                trickList: tricks
            )
            .presentationDetents([.height(350)])
            .environmentObject(trickListVM)
        })
    }
}
