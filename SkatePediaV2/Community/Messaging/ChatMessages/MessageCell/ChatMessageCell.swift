//
//  ChatMessageCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import Kingfisher
import AVKit


struct ChatMessageCell: View {
    @StateObject var viewModel: ChatMessageCellViewModel
    
    let currentUser: User
    let userChat: UserChat
    let message: UserMessage
    private var messageIsCurrentUsers: Bool
    
    init(currentUser: User, userChat: UserChat, message: UserMessage) {
        self.currentUser = currentUser
        self.userChat = userChat
        self.message = message
        self.messageIsCurrentUsers = currentUser.userId == message.fromUserId
        _viewModel = StateObject(wrappedValue: ChatMessageCellViewModel(message: message))
    }
    
    var body: some View {
        Group {
            if messageIsCurrentUsers {
                currentUserCell
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .trailing)
                    ))
                
            } else {
                otherUserCell
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .leading)
                    ))
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }
    
    var currentUserCell: some View {
        HStack(alignment: .center, spacing: 4) {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                
                if let fileType = message.fileType { filePreview(fileType: fileType) }
                
                Text(message.content)
                    .foregroundStyle(.white)
                    .fontWeight(.medium)
                    .frame(minWidth: 50, alignment: .center)
                    .padding(12)
                    .background(Color("buttonColor"))
                    .cornerRadius(20)
            }
            
            CircularProfileImageView(photoUrl: currentUser.photoUrl, size: .medium)
        }
        .padding(.leading, 50)
    }
    
    var otherUserCell: some View {
        HStack(alignment: .center, spacing: 4) {
            CircularProfileImageView(photoUrl: userChat.withUserData.photoUrl, size: .medium)

            VStack(alignment: .leading, spacing: 0) {
                
                if let fileType = message.fileType { filePreview(fileType: fileType) }
                
                Text(message.content)
                    .foregroundStyle(.primary)
                    .fontWeight(.medium)
                    .frame(minWidth: 50, alignment: .center)
                    .padding(12)
                    .background(.gray.opacity(0.5))
                    .cornerRadius(20)
            }
            
            Spacer()
        }
        .padding(.trailing, 50)
    }
    
    @ViewBuilder
    func filePreview(fileType: FileType) -> some View {
        if let player = viewModel.videoPlayer {
            VideoPlayer(player: player)
                .scaledToFit()
                .frame(maxWidth: UIScreen.screenWidth * 0.8)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
        } else if let image = viewModel.kfiImage {
            image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: UIScreen.screenWidth * 0.8)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}
