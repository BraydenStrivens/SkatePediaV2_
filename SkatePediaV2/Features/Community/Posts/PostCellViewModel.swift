//
//  PostCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/25/25.
//

import Foundation
import AVKit

/// Used to intialize a post's video player outside the body of a view. This prevents the video from being updated and flickering every time a @State variable
/// changes.
final class PostCellViewModel: ObservableObject {
    var player: AVPlayer
    
    private let useCases: PostUseCases
    private let errorStore: ErrorStore
    
    init(
        videoUrl: String,
        useCases: PostUseCases,
        errorStore: ErrorStore
    ) {
        self.player = AVPlayer(url: URL(string: videoUrl)!)
        self.useCases = useCases
        self.errorStore = errorStore
    }
    
    func deletePost(_ toDelete: Post) async {
        do {
            try await useCases.delete(toDelete)
        } catch {
            await errorStore.present(error, title: "Error Deleting Post")
        }
    }
}
