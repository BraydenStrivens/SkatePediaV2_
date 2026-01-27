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
    
    let currentUser: User
    let message: UserMessage
    private var messageIsCurrentUsers: Bool
    
    init(currentUser: User, message: UserMessage) {
        self.currentUser = currentUser
        self.message = message
        self.messageIsCurrentUsers = currentUser.userId == message.fromUserId
    }
    
    var body: some View {
        if messageIsCurrentUsers {
            currentUserCell
            
        } else {
            otherUserCell
        }
    }
    
    var currentUserCell: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                
                if let fileType = message.fileType { filePreview(fileType: fileType) }
                
                HStack {
                    Text(message.content)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: UIScreen.screenWidth * 0.8)
                .padding()
                .background(Color("AccentColor"))
                .cornerRadius(8)
            }
        }
    }
    
    var otherUserCell: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                
                if let fileType = message.fileType { filePreview(fileType: fileType) }
                
                HStack {
                    Text(message.content)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: UIScreen.screenWidth * 0.8)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.primary)
                }
                
                Spacer()
            }
            
            Spacer()
        }
        
    }
    
    func getPlayer(url: URL) -> AVPlayer {
        let player = AVPlayer(url: url)
        player.externalPlaybackVideoGravity = .resizeAspectFill
        
        return player
    }
    
    @ViewBuilder
    func filePreview(fileType: FileType) -> some View {
        
    }
    
    var filePreview: some View {
        HStack {
            if message.fileType == FileType.video.rawValue {
                let _ = print("MADE IT HERE")
                
                if let url = URL(string: message.fileUrl) {
                    let player = getPlayer(url: url)
                    
                    VideoPlayer(player: player)
                        .scaledToFit()
                        .frame(width: UIScreen.screenWidth * 0.8)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    let _ = print("COULDNT GET VIDEO URL")
                }
            } else {
                KFImage(URL(string: message.fileUrl)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.screenWidth * 0.8)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}

//#Preview {
//    ChatMessageCell()
//}
