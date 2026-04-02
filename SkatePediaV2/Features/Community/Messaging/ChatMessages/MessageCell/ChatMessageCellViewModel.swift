//
//  ChatMessageCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/26/26.
//

import Foundation
import AVKit
import Kingfisher

final class ChatMessageCellViewModel: ObservableObject {
    @Published var videoPlayer: AVPlayer? = nil
    @Published var kfiImage: KFImage? = nil
    
    @MainActor
    init(message: UserMessage) {
        if let fileType = message.fileType {
            switch fileType {
            case .photo:
                if let photoUrl = message.fileUrl {
                    self.kfiImage = KFImage(URL(string: photoUrl)!)
                }
                
            case .video:
                if let videoUrl = message.fileUrl {
                    self.videoPlayer = AVPlayer(url: URL(string: videoUrl)!)
                }
            }
        }
    }
}
