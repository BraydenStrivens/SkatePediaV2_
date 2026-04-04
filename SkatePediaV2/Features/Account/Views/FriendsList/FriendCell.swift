//
//  FriendCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import SwiftUI

/// View representing a user in the current user's friends list.
///
/// Displays basic user information and provides an action to remove
/// the friend via `FriendsListViewModel`.
///
/// - Parameters:
///   - friend: The friend data associated with this cell.
struct FriendCell: View {
    @EnvironmentObject var friendsListVM: FriendsListViewModel    
    @Environment(\.colorScheme) private var colorScheme

    let friend: Friend
    
#warning ("ADD DIRECT MESSAGE NAVIGATION PATH")
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            CircularProfileImageView(
                photoUrl: friend.withUserData.photoUrl,
                size: .medium
            )
            
            Text(friend.withUserData.username)
            
            Spacer()
            
            Button {
                Task {
                    await friendsListVM.handleFriend(
                        friend,
                        accept: false
                    )
                }
            } label: {
                Text("Remove")
                    .font(.subheadline)
                
            }
            .foregroundColor(.red)
            .padding(5)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.red, lineWidth: 1)
            }
            .padding(.horizontal, 8)
            .padding(5)
        }
        .padding(14)
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).protruded)
    }
}
