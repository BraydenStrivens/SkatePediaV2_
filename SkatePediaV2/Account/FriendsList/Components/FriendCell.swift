//
//  FriendCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import SwiftUI

struct FriendCell: View {
    let friend: Friend
    
    @Binding var friends: [Friend]
    
    var body: some View {
        
        if let user = friend.user {
            HStack(alignment: .center, spacing: 8) {
                CircularProfileImageView(user: user, size: .medium)
                
                UsernameHyperlink(user: user, font: .headline)

                Spacer()
                
                HStack(alignment: .center, spacing: 15) {
                    CustomNavLink(
                        destination: ChatMessagesView(chattingWith: user),
                        label: {
                            Image(systemName: "message")
                        }
                    )
                    .foregroundColor(.blue)
                    
                    Button {
                        UserManager.shared.removeFriend(toRemoveUid: friend.userId)
                        friends.removeAll { aFriend in
                            friend.userId == aFriend.userId
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
            }
        }
    }
}

//#Preview {
//    FriendCell()
//}
