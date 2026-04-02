//
//  FriendCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import SwiftUI

///
/// Defines the layout of a friend cell in the users friends list view. Contains functionality to to remove a user from the friends list.
///
///  - Parameters:
///     - friend: An object containing data about a user in the current user's friends list.
///     - friends: A list containing all of the current user's friends.
///
struct FriendCell: View {
    @EnvironmentObject var friendsListVM: FriendsListViewModel    
    @Environment(\.colorScheme) private var colorScheme

    let friend: Friend
    
#warning ("ADD DM NAV LINK")
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
