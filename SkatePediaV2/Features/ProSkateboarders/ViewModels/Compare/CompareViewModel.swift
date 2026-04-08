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

/// Represents which video slot is active in the compare view.
///
/// Used to track whether a video is assigned to the left or right side.
enum CompareVideoSlot: Identifiable {
    case left
    case right
    
    var id: Self {
        self
    }
}

/// Manages the state and behavior of the video comparison view.
///
/// Handles loading and caching videos for the left and right slots, synchronizing playback,
/// updating trick notes, and providing interfaces for swapping videos. Integrates with
/// `SPMultiVideoController` for multi-video playback control.
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
    let trickItemService: TrickItemService
    let trickItem: TrickItem?
    
    /// Creates a new `CompareViewModel` with optional left/right video initialization.
    ///
    /// - Parameters:
    ///   - errorStore: The shared error store for error handling.
    ///   - trickItemService: Service used for trick item operations. Defaults to `.shared`.
    ///   - trickItem: Optional trick item to display in the left slot.
    ///   - proVideo: Optional professional skater video to display in the right slot.
    init(
        errorStore: ErrorStore,
        trickItemService: TrickItemService = .shared,
        trickItem: TrickItem?,
        proVideo: ProSkaterVideo?
    ) {
        self.errorStore = errorStore
        self.trickItemService = trickItemService
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
    
    /// Returns `true` if the notes have been updated compared to the original trick item.
    var notesUpdated: Bool {
        trickItem?.notes != updatedTrickItemNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Sets a video to the specified slot (left or right) and prepares its player.
    ///
    /// - Parameters:
    ///   - video: The video to display.
    ///   - slot: The slot in which to place the video.
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
    
    /// Swaps the videos between the left and right slots.
    ///
    /// Player instances are preserved, and the multi-video controller is updated.
    func swapVideos() {
        let tempVideo = leftVideo
        let tempPlayer = leftPlayer
        
        leftVideo = rightVideo
        leftPlayer = rightPlayer
        
        rightVideo = tempVideo
        rightPlayer = tempPlayer
        
        attachPlayersToController()
    }
    
    /// Returns an existing AVPlayer for a video or creates a new one if not cached.
    ///
    /// - Parameter video: The video to get a player for.
    /// - Returns: A configured `AVPlayer` instance.
    func getOrCreatePlayer(for video: CompareVideo) -> AVPlayer {
        if let cached = playerCache[video.id] {
            return cached
        }
        
        let player = AVPlayer(url: video.url)
        player.actionAtItemEnd = .pause
        
        playerCache[video.id] = player
        
        return player
    }
    
    /// Attaches the left and right players to the multi-video controller.
    ///
    /// Pauses playback before attachment to avoid unintended playback.
    private func attachPlayersToController() {
        controller.pause()
        
        if let leftPlayerVM {
            controller.attach(leftPlayerVM)
        }
        
        if let rightPlayerVM {
            controller.attach(rightPlayerVM)
        }
    }
    
    /// Updates the notes for the current trick item in the backend.
    ///
    /// - Parameter trickItemId: The ID of the trick item to update.
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
}
