//
//  CompareVideoPlayer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/23/25.
//

import SwiftUI
import AVKit

struct CompareVideoPlayer: View {
    let frameSize: CGSize
    let videoData: VideoData
    let safeArea: EdgeInsets
    
    var body: some View {
        VStack {
            let player2 = AVPlayer(url: URL(string: videoData.videoUrl)!)
            
            let size = getNewAspectRatio(
                baseWidth: videoData.width,
                baseHeight: videoData.height,
                maxWidth: frameSize.width,
                maxHeight: frameSize.height
            )
            
            if let size = size {
                SPVideoPlayer(
                    userPlayer: player2,
                    frameSize: frameSize,
                    videoSize: size,
                    fullScreenSize: size,
                    safeArea: safeArea,
                    showButtons: false
                )
            }
        }
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
