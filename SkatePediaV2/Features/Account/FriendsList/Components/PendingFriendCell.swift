//
//  PendingFriend.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import SwiftUI
import FirebaseAuth

///
/// Defines the layout of a pending friend cell in the users friends list view. Contains functionality to to remove a pending user from the friends list.
///
///  - Parameters:
///     - pendingFriend: An object containing data about a user in the current user's friends list who is yet to be accepted.
///     - friends: A list containing all of the current user's pending friends.
///
struct PendingFriendCell: View {
    @EnvironmentObject var friendsListVM: FriendsListViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    let userId: String
    let pendingFriend: Friend
        
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            CircularProfileImageView(
                photoUrl: pendingFriend.withUserData.photoUrl,
                size: .medium
            )
            
            Text(pendingFriend.withUserData.username)
            
            Spacer()
            
            if userId == pendingFriend.senderUid {
                awaitingResponseView

            } else {
                respondToRequestButtons
            }
        }
        .padding(14)
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).protruded)
    }

    var awaitingResponseView: some View {
        VStack(alignment: .center) {
            Text("Awaiting response...")
                .foregroundStyle(.gray)
                .font(.caption)
            
            // Cancel sent friend request button
            Button {
                Task {
                    await friendsListVM.handleFriend(
                        pendingFriend,
                        accept: false
                    )
                }

            } label: {
                Text("Cancel")
                    .font(.caption2)
                    .underline()
            }
        }
    }
    
    var respondToRequestButtons: some View {
        HStack(spacing: 10) {
            // Accept friend request button
            Button {
                Task {
                    await friendsListVM.handleFriend(
                        pendingFriend,
                        accept: true
                    )
                }
            } label: {
                Text("Accept")
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary, lineWidth: 1)
                    }
            }
            .tint(Color.button)
            
            // Reject friend request button
            Button(role: .destructive) {
                Task {
                    await friendsListVM.handleFriend(
                        pendingFriend,
                        accept: false
                    )
                }

            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary, lineWidth: 1)
                    }
            }
        }
    }
}
