//
//  ProVideoCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/11/25.
//

import Foundation
import AVKit

final class ProVideoCellViewModel: ObservableObject {
    @Published var videoPlayer: AVPlayer? = nil

    @MainActor
    func setupVideoPlayer(videoUrl: String) {
        self.videoPlayer = AVPlayer(url: URL(string: videoUrl)!)
    }
    
    func getNewAspectRatio(baseWidth: CGFloat?, baseHeight: CGFloat?, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize? {
        guard let baseWidth = baseWidth, let baseHeight = baseHeight else {
            print("NO BASE ASPECT RATIO")
            return nil
        }
        
        let widthRatio = maxWidth / baseWidth
        let heightRatio = maxHeight / baseHeight
        
        if widthRatio < heightRatio {
            let newWidth = (baseWidth * widthRatio).rounded()
            let newHeight = (baseHeight * widthRatio).rounded()
            return CGSize(width: newWidth, height: newHeight)
        } else {
            let newWidth = (baseWidth * heightRatio).rounded()
            let newHeight = (baseHeight * heightRatio).rounded()
            return CGSize(width: newWidth, height: newHeight)
        }
    }
}
