//
//  UserChatCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/25/26.
//

import SwiftUI

struct UserChatCell: View {
    @EnvironmentObject var userChatsViewModel: UserChatsViewModel
    
    @State private var hasUnseenMessages: Bool
    let currentUser: User
    let userChat: UserChat
    
    init(currentUser: User, userChat: UserChat) {
        self.currentUser = currentUser
        self.userChat = userChat
        _hasUnseenMessages = State(initialValue: userChat.unseenMessageCount > 0)
    }
    
    var body: some View {
        CustomNavLink(
            destination: ChatMessagesView(
                currentUser: currentUser,
                withUserData: userChat.withUserData,
                userChat: userChat
            )
            .customNavBarItems(title: "", backButtonHidden: false)

        ) {
            HStack(alignment: .center) {
                // Chatting with user's profile photo
                CircularProfileImageView(photoUrl: userChat.withUserData.photoUrl, size: .large)
                
                VStack(alignment: .leading) {
                    Text(userChat.withUserData.username)
                        .foregroundColor(.primary)
                        .font(.headline)
                    
                    // Displays 'message sent' if current user was last to send message, otherwise
                    // displays a preview of the message send by the other user
                    if currentUser.userId == userChat.latestMessage?.fromUserId {
                        if let otherUserReadDate = userChat.otherUserReadDate {
                            Text("Read \(otherUserReadDate.timeAgoString())")
                                .font(.callout)
                                .foregroundStyle(.gray)
                            
                        } else {
                            Text("Message sent...")
                                .font(.callout)
                                .foregroundStyle(.gray)
                        }
                        
                    } else {
                        if userChat.unseenMessageCount <= 1 {
                            if let fileType = userChat.latestMessage?.fileType {
                                switch fileType {
                                case .photo:
                                    Text("Sent a photo.")
                                        .font(.callout)
                                    
                                case .video:
                                    Text("Sent a video.")
                                        .font(.callout)
                                }
                                
                            } else {
                                Text(userChat.latestMessage?.content.prefix(25) ?? "")
                                    .font(.callout)
                                    .fontWeight(!hasUnseenMessages ? .regular : .semibold)
                            }
                            
                        } else {
                            Text("Sent ")
                                .font(.callout)
                            + Text("\(userChat.unseenMessageCount)")
                                .font(.callout)
                                .fontWeight(.semibold)
                            + Text(" new messages!")
                                .font(.callout)
                        }
                    }
                }
                .foregroundStyle(!hasUnseenMessages ? .gray : .primary)

                Spacer()
                
                Text(userChat.latestMessage?.dateCreated.timeAgoString() ?? "")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        }
    }
}
