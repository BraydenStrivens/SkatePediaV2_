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
    @EnvironmentObject var trickListVM: TrickListViewModel
    let trick: Trick
    
    private let size: CGFloat = 20
    
    var body: some View {
        CustomNavLink(
            destination: TrickView(trick: trick)
                .customNavBarItems(title: trick.name, subtitle: "", backButtonHidden: false)
                .environmentObject(trickListVM)
        ) {
            HStack(alignment: .center, spacing: 12) {
                Text(trick.name)
                    .foregroundColor(.primary)
                    .font(.callout)
                
                Spacer()
                
                //Displays a symbol representing the user's progress in learning the trick
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
                            .foregroundColor(Color.button)
                            .frame(width: 20, height: 20)
                        
                    } else if maxRating == 1 {
                        Image(systemName: "circle.circle")
                            .resizable()
                            .foregroundColor(Color.button)
                            .frame(width: 20, height: 20)
                        
                    } else if maxRating == 2 {
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
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contextMenu {
                Button("Hide Trick From List") {
                    Task {
                        await trickListVM.hideTrick(trick: trick)
                    }
                }
                // The base tricks initially provided to the user have an id length of 8
                // and aren't allowed to be deleted. User added tricks have a longer id
                // length and are allowed to be deleted
                if trick.id.count != 8 {
                    Button("Delete From List", role: .destructive) {
                        Task {
                            await trickListVM.removeTrick(toRemove: trick)
                        }
                    }
                }
            }
        }
    }
}
