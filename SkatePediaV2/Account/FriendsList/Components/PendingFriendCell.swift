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
    let pendingFriend: Friend
    
    @Binding var pendingFriends: [Friend]
    
    var body: some View {
        if let user = pendingFriend.user {
            HStack(alignment: .center, spacing: 10) {
                // Profile Photo
                CircularProfileImageView(user: user, size: .medium)
                
                // Username hyperlink to the user's profile
                UsernameHyperlink(user: user, font: .headline)
                
                Spacer()
                
                // Detects if the current user sent the friend request or the pending friend sent the friend request.
                if pendingFriend.fromUid == Auth.auth().currentUser?.uid {
                    awaitingResponseView
                    
                } else {
                    respondToRequestButtons
                }
            }
        }
    }

    var awaitingResponseView: some View {
        VStack(alignment: .center) {
            Text("Awaiting response...")
                .foregroundColor(.gray)
                .font(.caption)
            
            // Cancel sent friend request button
            Button {
                UserManager.shared.removeFriend(toRemoveUid: pendingFriend.userId)
                removeFromList()

            } label: {
                Text("Cancel")
                    .font(.caption2)
            }
            .foregroundColor(.red)
        }
    }
    
    var respondToRequestButtons: some View {
        HStack(spacing: 10) {
            // Accept friend request button
            Button {
                Task {
                    try await UserManager.shared.acceptFriendRequest(senderUid: pendingFriend.userId)
                    removeFromList()

                }
            } label: {
                Text("Accept")
                    .font(.subheadline)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary, lineWidth: 1)
                    }
                    .padding(5)
            }
            
            // Reject friend request button
            Button {
                UserManager.shared.removeFriend(toRemoveUid: pendingFriend.userId)
                removeFromList()

            } label: {
                Text("Reject")
                    .font(.subheadline)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary, lineWidth: 1)
                    }
                    .padding(5)
            }
        }
        .foregroundColor(.primary)
    }
    
    ///
    /// Removes the passed pending friend parameter from the displayed list of friends (does not remove from database).
    ///
    func removeFromList() {
        withAnimation(.easeInOut(duration: 0.5)) {
            pendingFriends.removeAll { aPendingFriend in
                pendingFriend.userId == aPendingFriend.userId
            }
        }
    }
}
