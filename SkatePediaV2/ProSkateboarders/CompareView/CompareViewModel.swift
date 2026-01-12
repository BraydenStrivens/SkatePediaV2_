//
//  CompareViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/12/25.
//

import Foundation
import FirebaseAuth
import AVKit

enum CompareVideoSlot: Identifiable {
    case left
    case right
    
    var id: Self {
        self
    }
}

final class CompareViewModel: ObservableObject {
    @Published var trick: Trick? = nil
    @Published var trickFetchState: RequestState = .idle

    @Published var leftVideo: CompareVideo?
    @Published var rightVideo: CompareVideo?
    @Published var activeSlot: CompareVideoSlot?
    
    @Published var videoPlayer1: AVPlayer? = nil
    @Published var videoPlayer2: AVPlayer? = nil
    
    @Published var updatedTrickItemNotes: String = ""

    @MainActor
    func fetchTrick(trickId: String) async {
        do {
            self.trickFetchState = .loading
            self.trick = try await TrickListManager.shared.getTrick(trickId: trickId)
            self.trickFetchState = .success
            
        } catch let error as FirestoreError {
            self.trickFetchState = .failure(error)
            
        } catch {
            self.trickFetchState = .failure(.unknown)
        }
    }
    
    @MainActor
    func initialVideoSetup(trickItem: TrickItem? = nil, proVideo: ProSkaterVideo? = nil) {
        if let trickItem = trickItem {
            self.leftVideo = .trickItem(trickItem)
        }
        if let proVideo = proVideo {
            self.rightVideo = .proVideo(proVideo)
        }
    }
    
    @MainActor
    func updateAVPlayer(slot: CompareVideoSlot, url: String) {
        switch slot {
        case .left:
            self.videoPlayer1 = AVPlayer(url: URL(string: url)!)
        case .right:
            self.videoPlayer2 = AVPlayer(url: URL(string: url)!)
        }
    }
    
    func updateTrickItemNotes(trickItemId: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Task {
            try await TrickItemManager.shared.updateTrickItemNotes(userId: currentUid, trickItemId: trickItemId, newNotes: updatedTrickItemNotes)
        }
    }
}
