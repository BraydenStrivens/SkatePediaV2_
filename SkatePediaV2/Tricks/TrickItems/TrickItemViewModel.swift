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
    
    @Published var edit: Bool = false
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
    
    @Published var updateTrickItemState: RequestState = .idle
    @Published var deleteTrickItemState: RequestState = .idle
    
    func updateTrickItem(userId: String, trickItemId: String) async {
        do {
            self.updateTrickItemState = .loading
            
            try await TrickItemManager.shared.updateTrickItemNotes(userId: userId, trickItemId: trickItemId, newNotes: newNotes)
            
            self.updateTrickItemState = .success
            
            withAnimation(.easeInOut(duration: 0.3)) {
                self.edit = false
            }
        } catch let error as FirestoreError {
            self.updateTrickItemState = .failure(.firestore(error))
            
        } catch {
            self.updateTrickItemState = .failure(.unknown)
        }
    }
    
    func deleteTrickItem(userId: String, trickItem: TrickItem, trick: Trick) async {
        do {
            self.deleteTrickItemState = .loading
                        
            try await TrickItemManager.shared.deleteTrickItem(userId: userId, trickItem: trickItem, trick: trick)
            
            // If the user only has one trick item for a trick, reset the trick's 'hasTrickItems' attribute
            if trick.progress.count == 1 {
                try await TrickListManager.shared.updateTrickHasTrickItemsField(
                    userId: userId,
                    trickId: trickItem.trickId,
                    hasItems: false
                )
            }
            
            self.deleteTrickItemState = .success
            self.edit = false
            
        } catch let error as FirestoreError {
            self.deleteTrickItemState = .failure(.firestore(error))
            
        } catch {
            self.deleteTrickItemState = .failure(.unknown)
        }
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
