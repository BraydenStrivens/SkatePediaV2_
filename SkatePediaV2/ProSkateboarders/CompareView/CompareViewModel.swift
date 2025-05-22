//
//  CompareViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/12/25.
//

import Foundation
import FirebaseAuth
import AVKit

final class CompareViewModel: ObservableObject {
    @Published var trick: Trick? = nil
    @Published var loading: Bool = false
    @Published var updatedTrickItemNotes: String = ""
    
    @Published var videoPlayer1: AVPlayer? = nil
    @Published var videoPlayer2: AVPlayer? = nil
    @Published var settingPlayer1: Bool = false
    @Published var settingPlayer2: Bool = false
    
    @Published var selectedTrickItem: TrickItem? = nil
    @Published var selectedProVideo: ProSkaterVideo? = nil
    @Published var selectedSecondTrickItem: TrickItem? = nil
    
    @MainActor
    func fetchTrick(trickId: String) async throws {
        self.loading = true
        self.trick = try await TrickListManager.shared.getTrick(trickId: trickId)
        self.loading = false
    }
    
    @MainActor
    func setSelectedItem(trickItem: TrickItem? = nil, proVideo: ProSkaterVideo? = nil, secondTrickItem: TrickItem? = nil) {
        if let trickItem = trickItem {
            self.settingPlayer1 = true
            
            self.selectedTrickItem = trickItem
            self.videoPlayer1 = AVPlayer(url: URL(string: trickItem.videoData.videoUrl)!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.settingPlayer1 = false
            }
        }
        
        if let proVideo = proVideo {
            self.settingPlayer2 = true
            
            self.selectedProVideo = proVideo
            self.selectedSecondTrickItem = nil
            self.videoPlayer2 = AVPlayer(url: URL(string: proVideo.videoData.videoUrl)!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.settingPlayer2 = false
            }
        }
        
        if let secondTrickItem = secondTrickItem {
            self.settingPlayer2 = true
            
            self.selectedSecondTrickItem = secondTrickItem
            self.selectedProVideo = nil
            self.videoPlayer2 = AVPlayer(url: URL(string: secondTrickItem.videoData.videoUrl)!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.settingPlayer2 = false
            }
        }
    }
    
    func updateTrickItemNotes(trickItemId: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Task {
            try await TrickItemManager.shared.updateTrickItemNotes(userId: currentUid, trickItemId: trickItemId, newNotes: updatedTrickItemNotes)
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
