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
/// Also provides contextual actions via a long-press menu, including:
/// - Hiding the trick from the list
/// - Deleting the trick from the list (when allowed)
///
/// - Parameters:
///   - userId: The ID of the current user.
///   - trick: The trick model displayed in this cell.
///   - viewModel: View model responsible for handling user actions (hide/delete).
struct TrickListCell: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject private var router: TrickListRouter
    
    @StateObject var viewModel: TrickListCellViewModel
    let userId: String
    var trick: Trick
    
    init(
        userId: String,
        trick: Trick,
        viewModel: TrickListCellViewModel
    ) {
        self.userId = userId
        self.trick = trick
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private let size: CGFloat = 20
    
    var body: some View {
        Button {
            // Navigate to detailed trick view
            router.push(.trick(userId: userId, trick: trick))
        } label: {
            HStack(alignment: .center, spacing: 12) {
                
                /// Displays trick name using abbreviation settings if enabled.
                Text(trick.displayName(useAbbreviation: userStore.trickSettings?.useTrickAbbreviations == true))
                    .foregroundColor(.primary)
                    .font(.callout)
                
                Spacer()
                
                trickProgressImage
            }
            .contentShape(Rectangle())
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contextMenu {
                trickCellOptions
            }
        }
    }
    
    /// Context menu actions for managing the trick.
    ///
    /// Provides options to hide or delete the trick from the user's list.
    ///
    /// - Important:
    ///   Delete option is only shown for user-created tricks (non-default IDs).
    var trickCellOptions: some View {
        Group {
            Button("Hide Trick From List") {
                Task {
                    await viewModel.hideTrick(
                        userId: userId,
                        trick: trick
                    )
                }
            }
            if trick.id.count != 8 {
                Button("Delete From List", role: .destructive) {
                    Task {
                        await viewModel.deleteTrick(trick)
                    }
                }
            }
        }
    }
    
    /// Visual indicator representing the user's progress on the trick.
    ///
    /// Maps progress rating values to SF Symbol states:
    /// - 0: empty circle
    /// - 1: partial circle
    /// - 2: mostly filled circle
    /// - 3+: checkmark circle
    ///
    /// If no progress exists, shows a default circle.
    var trickProgressImage: some View {
        if let highestRating = trick.progressCounts.highestRating {
            if highestRating == 0 {
                Image(systemName: "circle")
                    .resizable()
                    .foregroundColor(Color.button)
                    .frame(width: 20, height: 20)
                
            } else if highestRating == 1 {
                Image(systemName: "circle.circle")
                    .resizable()
                    .foregroundColor(Color.button)
                    .frame(width: 20, height: 20)
                
            } else if highestRating == 2 {
                Image(systemName: "circle.circle.fill")
                    .resizable()
                    .foregroundColor(Color.button)
                    .frame(width: 20, height: 20)
                
            } else {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .foregroundColor(Color.button)
                    .frame(width: 20, height: 20)
            }
        } else {
            Image(systemName: "circle")
                .resizable()
                .foregroundColor(.primary)
                .frame(width: 20, height: 20)
        }
    }
}
