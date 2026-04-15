//
//  TrickListViewByStance.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

/// A view that displays a user's trick list filtered by stance, grouped by difficulty.
///
/// Shows progress for the selected stance, organized difficulty sections, and provides
/// tools for managing the trick list, including adding, hiding, and resetting hidden tricks.
///
/// Each difficulty level is displayed using a `DifficultyCard`, and tricks are grouped
/// dynamically from the `TrickListStore`.
///
/// This view requires shared environment objects for routing, user state,
/// error handling, and trick list management.
///
/// - Important:
///   Requires `TrickListStore` to provide grouped trick data and refresh updates after changes.
///
/// - Parameters:
///   - userId: The ID of the current user.
///   - stance: The stance used to filter the trick list.
///   - resetHidden: Async action used to reset hidden tricks for the stance.
struct TrickListViewByStance: View {
    @EnvironmentObject private var router: TrickListRouter
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var trickListStore: TrickListStore
    @EnvironmentObject var errorStore: ErrorStore
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAddTrickView = false
    
    let userId: String
    let stance: TrickStance
    /// Action used to restore hidden tricks for this stance.
    let resetHidden: () async -> Void
    
    var groupedTricks: [TrickDifficulty : [Trick]] {
        trickListStore.groupedTricks(stance: stance)
    }
    
    var body: some View {
        Group {
            if groupedTricks.isEmpty {
                ContentUnavailableView(
                    "No Tricks Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Failed to fetch \(stance.camalCase) tricks...")
                )
                
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            /// Progress summary for the selected stance.
                            TrickListInfoView(stance: stance)
                            
                            HStack(alignment: .center) {
                                /// Options menu for list management actions.
                                Menu {
                                    Button("Reset Hidden Tricks") {
                                        Task {
                                            await resetHidden()
                                        }
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .tint(.primary)
                                        .padding(.horizontal)
                                }
                                
                                Spacer()
                                
                                /// Button to present the add trick sheet.
                                Button {
                                    withAnimation(.smooth) {
                                        showAddTrickView.toggle()
                                    }
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
                        
                        /// Displays tricks grouped by difficulty level.
                        ForEach(TrickDifficulty.allCases) { difficulty in
                            DifficultyCard(
                                userId: userId,
                                difficulty: difficulty,
                                stance: stance,
                                tricks: groupedTricks[difficulty] ?? []
                            )
                        }
                    }
                    .padding(.vertical, 12)
                }
                .scrollIndicators(.hidden)
            }
        }
        .spSheet(
            isPresented: $showAddTrickView,
            detent: .half
        ) {
            AddTrickBuilder.build(
                userId: userId,
                stance: stance,
                trickList: groupedTricks.flatMap(\.value),
                errorStore: errorStore,
                trickListStore: trickListStore
            )
        }
    }
}
