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
import Combine

@MainActor
final class TrickItemViewModel: ObservableObject {
    @Published var newNotes: String = ""
    @Published var newRating: Int = -1
    
    @Published var updateLoading: Bool = false
    @Published var deleteLoading: Bool = false
    
    @Published private(set) var post: Post?
    let videoPlayer: AVPlayer
    
    private let trickItemUseCases: TrickItemUseCases
    private let postUseCases: PostUseCases
    private let errorStore: ErrorStore

    init(
        trickItemUseCases: TrickItemUseCases,
        postUseCases: PostUseCases,
        errorStore: ErrorStore,
        trickItem: TrickItem
    ) {
        self.trickItemUseCases = trickItemUseCases
        self.postUseCases = postUseCases
        self.errorStore = errorStore
        
        self.newNotes = trickItem.notes
        self.newRating = trickItem.progress
        self.videoPlayer = AVPlayer(url: URL(string: trickItem.videoData.videoUrl)!)
    }
    
    func editToggled(currentTrickItem: TrickItem) {
        self.newNotes = currentTrickItem.notes
        self.newRating = currentTrickItem.progress
    }
    
    func syncUpdates(newTrickItem: TrickItem) {
        newNotes = newTrickItem.notes
        newRating = newTrickItem.progress
    }
    
    func fetchTrickItemPost(trickItem: TrickItem) async {
        guard trickItem.postedAt != nil else { return }
        do {
            try await postUseCases.fetchPost(for: trickItem.id)
        } catch {
            errorStore.present(error, title: "")
        }
    }
    
    func updateTrickItem(userId: String, currentTrickItem: TrickItem) {
        updateLoading = true
        defer { updateLoading = false }
        
        let request = UpdateTrickItemRequest(
            currentItem: currentTrickItem,
            userId: userId,
            newNotes: newNotes,
            newRating: newRating
        )
        
        do {
            try trickItemUseCases.update(request)
        } catch {
            errorStore.present(error, title: "Error Updating Trick Item")
        }
    }
    
    func deleteTrickItem(toDelete: TrickItem) async -> Bool {
        deleteLoading = true
        defer { deleteLoading = false }
        
        do {
            try await trickItemUseCases.delete(toDelete)
            return true
        } catch {
            errorStore.present(error, title: "Error Deleting Trick Item")
            return false
        }
    }
}
