//
//  CustomVideoPlayer.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/30/24.
//

import SwiftUI
import AVKit
import Foundation


/// Defines a custom video player for use throughout the app.
///
/// - Parameters:
///  - player: An 'AVPlayer' object that contains the video url of the video to be displayed.
struct CustomVideoPlayer: UIViewControllerRepresentable {
    
    var player: AVPlayer
    
    /// Creates a player view controller
    ///
    /// - Returns: The player controller object.
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.allowsVideoFrameAnalysis = true
        controller.videoGravity = .resizeAspectFill
        
        controller.view.isUserInteractionEnabled = false
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player !== player {
            uiViewController.player = player
        }
    }

    
    @MainActor
    static func getVideoResolution(url: String) async throws -> CGSize? {
        do {
            let url = URL(string: url)
            let track = try await AVURLAsset(url: url!).loadTracks(withMediaType: AVMediaType.video).first
            let size = try await track!.load(.naturalSize).applying(track!.load(.preferredTransform))
            
            return CGSize(width: abs(size.width), height: abs(size.height))
        } catch {
            print("ERROR: \(error)")
        }

        return nil
    }
    
    static func getNewAspectRatio(baseWidth: CGFloat?, baseHeight: CGFloat?, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize? {
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
