//
//  TrickItemViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation
import SwiftUI
import AVKit
import PhotosUI

@MainActor
final class TrickItemViewModel: ObservableObject {
    
    @Published var newNotes: String = ""
    @Published var newRating: Int = 0
    @Published var savingTrickItem: Bool = false
    @Published var selectedAVideo: Bool = false
    @Published var videoPlayer: AVPlayer? = nil
    @Published var videoAspectRatio: CGSize? = nil
    @Published var newVideo: PhotosPickerItem? {
        didSet {
            selectedAVideo = true
        }
    }
    
    func updateTrickItem(userId: String, trickItemId: String) async throws {
        self.savingTrickItem = true
        try await TrickItemManager.shared.updateTrickItemNotes(userId: userId, trickItemId: trickItemId, newNotes: newNotes)
        self.savingTrickItem = false
    }
    
    func deleteTrickItem(userId: String, trickItem: TrickItem) async throws {
        try await TrickItemManager.shared.deleteTrickItem(userId: userId, trickItem: trickItem)
    }
    
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
