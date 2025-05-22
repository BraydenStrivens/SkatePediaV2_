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
    let message: Message
    
    init(message: Message) {
        self.message = message
        self.isCurrentUser = message.fromUserId == Auth.auth().currentUser?.uid
    }
    var isCurrentUser: Bool
    
    var body: some View {
        if isCurrentUser {
            currentUserCell
        } else {
            otherUserCell
        }
        
    }
    
    var currentUserCell: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                
                if message.fileType != FileType.none.rawValue { filePreview }
                
                HStack {
                    Text(message.content)
                        .foregroundColor(isCurrentUser ? .white : .primary)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
    }
    
    var otherUserCell: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                
                if message.fileType != FileType.none.rawValue { filePreview }
                
                HStack {
                    Text(message.content)
                        .foregroundColor(isCurrentUser ? .white : .primary)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.primary)
                }
                //                .cornerRadius(8)
                
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
