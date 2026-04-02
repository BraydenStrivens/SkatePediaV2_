//
//  TrickListCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/3/26.
//

import SwiftUI

/// Custom view that displays information for a trick and a link to navigate to the "Trick View" for that trick.
/// Displays the name of the trick and a symbol representing the user's progress in learning the trick if
/// the user hasn't set it as hidden.
///
/// - Parameters:
///  - userId: The id of the current user.
///  - trick: A struct containing information about a trick.
///  - trickListInfo: A struct containing info about the user's trick list
///
struct TrickListCell: View {
    @EnvironmentObject var userStore: UserStore
    
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
        NavigationLink(
            destination: TrickViewContainer(userId: userId, trick: trick)
        ) {
            HStack(alignment: .center, spacing: 12) {
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
    }
    
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
