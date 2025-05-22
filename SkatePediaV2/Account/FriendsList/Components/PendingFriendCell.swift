//
//  PendingFriend.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import SwiftUI
import FirebaseAuth

struct PendingFriendCell: View {
    let pendingFriend: Friend
    
    @Binding var pendingFriends: [Friend]
    
    var body: some View {
        if let user = pendingFriend.user {
            HStack(alignment: .center, spacing: 10) {
                CircularProfileImageView(user: user, size: .medium)
                
                UsernameHyperlink(user: user, font: .headline)
                
                Spacer()
                
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
    
    func removeFromList() {
        withAnimation(.easeInOut(duration: 0.5)) {
            pendingFriends.removeAll { aPendingFriend in
                pendingFriend.userId == aPendingFriend.userId
            }
        }
    }
}
