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
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: TrickListRouter
    @EnvironmentObject private var appEnv: AppEnvironment
    @EnvironmentObject private var trickListStore: TrickListStore
    @EnvironmentObject private var errorStore: ErrorStore
    
    // MARK: State
    @State private var showAddTrickView = false
    
    // MARK: Parameters
    let userId: String
    let stance: TrickStance
    let resetHidden: () async -> Void /// Action used to restore hidden tricks for this stance.
    
    // MARK: Derived Properties
    private var groupedTricks: [TrickDifficulty : [Trick]] {
        trickListStore.groupedTricks(stance: stance)
    }
    
    // MARK: Body
    var body: some View {
        Group {
            if groupedTricks.isEmpty {
                SPContentUnavailableView(
                    title: "No Tricks Found",
                    description: "Failed to fetch \(stance.camalCase) tricks.",
                    type: .emptyList
                )
                
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        stanceHeader
                        
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
                appEnv: appEnv,
                errorStore: errorStore
            )
        }
    }
    
    // MARK: Subviews
    
    /// Displays the user's progress for tricks of a specific stance, a button to reset hidden tricks
    /// for the stance, and a button to add a new trick for the stance.
    private var stanceHeader: some View {
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
    }
}
