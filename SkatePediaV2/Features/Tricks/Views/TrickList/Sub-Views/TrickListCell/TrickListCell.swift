//
//  TrickListCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/3/26.
//

import SwiftUI

/// Custom row view that displays a single trick in a list.
///
/// Shows the trick name and a visual indicator of the user's progress level.
/// Tapping the cell navigates to the detailed `Trick` view.
///
/// Also displays option buttons when edit is toggled from `TrickListView`
/// - Selecting trick as a 'favorite'
/// - Hiding the trick from the list
/// - Deleting the trick from the list (when allowed)
///
/// - Parameters:
///   - userId: The ID of the current user.
///   - trick: The trick model displayed in this cell.
///   - viewModel: View model responsible for handling user actions (hide/delete).
struct TrickListCell: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: TrickListRouter
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var trickListVM: TrickListViewModel
    
    // MARK: State
    @State private var toggleNameChange: Bool = false
    
    // MARK: Parameters
    @StateObject var viewModel: TrickListCellViewModel
    let userId: String
    var trick: Trick
    
    // MARK: Derived/Private Properties
    private let size: CGFloat = 20
    private var isFavoriteTrick: Bool {
        userStore.isFavoriteTrick(trick.id)
    }
    
    // MARK: Init
    init(
        userId: String,
        trick: Trick,
        viewModel: TrickListCellViewModel
    ) {
        self.userId = userId
        self.trick = trick
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: Body
    var body: some View {
        Button {
            router.push(
                .trick(userId: userId, trick: trick),
                hasAnimation: true
            )
        } label: {
            HStack(alignment: .center, spacing: 12) {
                
                Text(userStore.getTrickName(trick))
                    .foregroundColor(.primary)
                    .font(.callout)
                    .padding(.vertical, 12)
                
                if trickListVM.toggleEdit {
                    Button {
                        toggleNameChange = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
                
                Spacer()
                
                if trickListVM.toggleEdit {
                    trickCellOptions
                    
                } else {
                    if isFavoriteTrick {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    
                    TrickProgressBadge(rating: trick.progressCounts.highestRating)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal)
        }
        .buttonStyle(PressableCellStyle(
            backgroundColor: Color.clear,
            pressedColor: Color(.systemGray5)
        ))
        .spSheet(isPresented: $toggleNameChange, detent: .half) {
            ChangeTrickNameSheet(
                trick: trick,
                onSave: { newName, newAbbreviation in 
                    await viewModel.setCustomName(
                        userId: userId,
                        trick: trick,
                        newName: newName,
                        newAbbreviation: newAbbreviation
                    )
                }
            )
        }
    }
    
    // MARK: Subviews
    
    /// Buttons for managing the trick.
    ///
    /// Provides options to favorite, hide, or delete the trick from the user's list.
    ///
    /// - Important:
    ///   Delete option is only shown for user-created tricks (non-default IDs).
    private var trickCellOptions: some View {
        HStack(spacing: 24) {
            // Favorite button
            Image(systemName: isFavoriteTrick ? "star.fill" : "star")
                .foregroundColor(isFavoriteTrick ? .yellow : .primary)
                .contentShape(Rectangle())
                .onTapGesture {
                    Task {
                        await viewModel.toggleFavorite(
                            trick.id,
                            currentFavorites: userStore.favoriteTricks ?? [],
                            userId: userId)
                    }
                }
            
            // Hide button
            cellOptionButton(
                "Hide",
                image: "eye.slash",
                color: Color.button,
                onClick: {
                    await viewModel.hideTrick(userId: userId, trick: trick)
                }
            )
            
            // Delete button
            if trick.id.count != 8 {
                if viewModel.isDeleting {
                    ProgressView()
                    
                } else {
                    cellOptionButton(
                        "Delete",
                        image: "trash",
                        color: .red,
                        onClick: {
                            await viewModel.deleteTrick(trick)
                        }
                    )
                }
            }
        }
    }
    
    /// Creates a compact action button used for cell-level actions.
    ///
    /// Displays a vertically stacked SF Symbol and label, and executes
    /// an asynchronous action when tapped.
    ///
    /// - Parameters:
    ///   - text: The caption displayed beneath the icon.
    ///   - image: The SF Symbol name displayed above the text label.
    ///   - color: The foreground color applied to both the icon and text.
    ///   - onClick: An asynchronous action executed when the button is tapped.
    ///
    /// - Returns: A styled button view configured for compact cell actions.
    private func cellOptionButton(
        _ text: String,
        image: String,
        color: Color,
        onClick: @escaping () async -> Void
    ) -> some View {
        Button {
            Task {
                await onClick()
            }
        } label: {
            VStack {
                Image(systemName: image)
                Text(text)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .foregroundColor(color)
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}
