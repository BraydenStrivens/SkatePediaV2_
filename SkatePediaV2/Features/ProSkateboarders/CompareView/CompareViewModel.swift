//
//  CompareViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/12/25.
//

import Foundation
import SwiftUI
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
    
    @Published var leftVideo: CompareVideo?
    @Published var rightVideo: CompareVideo?
    @Published var activeSlot: CompareVideoSlot?
    @Published var isSyncing: Bool = false
    
    private(set) var leftPlayer: AVPlayer?
    private(set) var leftPlayerVM: SPVideoPlayerViewModel2?
    private(set) var rightPlayer: AVPlayer?
    private(set) var rightPlayerVM: SPVideoPlayerViewModel2?
    private var playerCache: [String: AVPlayer] = [:]
    
    @Published var updatedTrickItemNotes: String
    @Published var controller = SPMultiVideoController()
    
    let errorStore: ErrorStore
    let useCases: TrickItemUseCases
    let trickItem: TrickItem?
    
    init(
        errorStore: ErrorStore,
        useCases: TrickItemUseCases,
        trickItem: TrickItem?,
        proVideo: ProSkaterVideo?
    ) {
        self.errorStore = errorStore
        self.useCases = useCases
        self.trickItem = trickItem
        _updatedTrickItemNotes = Published(initialValue: trickItem?.notes ?? "")
        
        if let trickItem {
            let video: CompareVideo = .trickItem(trickItem)
            setVideo(video, for: .left)
        }
        if let proVideo {
            let video: CompareVideo = .proVideo(proVideo)
            setVideo(video, for: .right)
        }
    }
    
    var notesUpdated: Bool {
        trickItem?.notes != updatedTrickItemNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    func setVideo(_ video: CompareVideo, for slot: CompareVideoSlot) {
        let player = getOrCreatePlayer(for: video)
        player.seek(to: .zero)
        
        switch slot {
        case .left:
            leftVideo = video
            leftPlayer = player
            leftPlayerVM = SPVideoPlayerViewModel2(player: player)
            
        case .right:
            rightVideo = video
            rightPlayer = player
            rightPlayerVM = SPVideoPlayerViewModel2(player: player)
        }
        
        attachPlayersToController()
    }
    
    func swapVideos() {
        let tempVideo = leftVideo
        let tempPlayer = leftPlayer
        
        leftVideo = rightVideo
        leftPlayer = rightPlayer
        
        rightVideo = tempVideo
        rightPlayer = tempPlayer
        
        attachPlayersToController()
    }
    
    func getOrCreatePlayer(for video: CompareVideo) -> AVPlayer {
        if let cached = playerCache[video.id] {
            return cached
        }
        
        let player = AVPlayer(url: video.url)
        player.actionAtItemEnd = .pause
        
        playerCache[video.id] = player
        
        return player
    }
    
    private func attachPlayersToController() {
        controller.pause()
        
        if let leftPlayerVM {
            controller.attach(leftPlayerVM)
        }
        
        if let rightPlayerVM {
            controller.attach(rightPlayerVM)
        }
    }
    
    @MainActor
    func updateTrickItemNotes(trickItemId: String) async {
        do {
            guard let currentUid = Auth.auth().currentUser?.uid else {
                throw AuthError.invalidCredential
            }

            try await TrickItemManager.shared.updateTrickItemNotes(userId: currentUid, trickItemId: trickItemId, newNotes: updatedTrickItemNotes)
        } catch {
            errorStore.present(error, title: "Error Updating Notes")
        }
    }
    
    func syncVideos() {
        guard let leftVideo, let rightVideo else { return }
        
        isSyncing = true
        controller.pause()
        
        Task {
            do {
                async let t1 = VideoSyncService.shared.findSyncTime(for: leftVideo.url)
                async let t2 = VideoSyncService.shared.findSyncTime(for: rightVideo.url)
                
                guard let time1 = try await t1,
                      let time2 = try await t2 else {
                    await MainActor.run { self.isSyncing = false }
                    return
                }
                
                let cmTime1 = CMTime(seconds: time1, preferredTimescale: 600)
                let cmTime2 = CMTime(seconds: time2, preferredTimescale: 600)
                
                await MainActor.run {
                    self.leftPlayer?.seek(to: cmTime1, toleranceBefore: .zero, toleranceAfter: .zero)
                    self.rightPlayer?.seek(to: cmTime2, toleranceBefore: .zero, toleranceAfter: .zero)
                }
                
                try await Task.sleep(nanoseconds: 150_000_000)
                
                await MainActor.run {
                    self.isSyncing = false
                    self.controller.play()
                }
                
            } catch {
                await MainActor.run {
                    self.isSyncing = false
                    errorStore.present(error, title: "Error Syncing Videos")
                }
            }
        }
    }
}
