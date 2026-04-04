//
//  PendingFriend.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import SwiftUI
import FirebaseAuth

/// View representing a pending friend request item.
///
/// Displays user information and provides actions to either respond
/// to or cancel a friend request depending on the current user's role.
///
/// - Parameters:
///   - userId: The ID of the current user.
///   - pendingFriend: The pending friend relationship data.
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

    /// View displayed when the current user has sent the request.
    ///
    /// Shows a waiting state with an option to cancel the request.
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
    
    /// View displaying actions to respond to an incoming request.
    ///
    /// Provides options to accept or reject the friend request.
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
