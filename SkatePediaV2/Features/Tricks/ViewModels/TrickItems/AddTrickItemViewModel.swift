//
//  AddTrickItemViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/6/25.
//

import Foundation
import PhotosUI
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

/// View model responsible for creating and uploading a Trick Item.
///
/// Handles video selection, preview preparation, validation,
/// upload orchestration, and local store updates.
///
/// Coordinates between `VideoUploadService`, `TrickItemService`,
/// and `TrickItemStore` to complete the upload flow.
///
/// - Important: This ViewModel owns the full upload lifecycle including
///              validation, compression, upload progress, and persistence.
@MainActor
final class AddTrickItemViewModel: ObservableObject {
    @Published var notes: String = ""
    @Published var progress: Int = 0
    
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedVideoURL: URL?
    @Published var videoSize: CGSize?
    @Published var loadingVideoPreview: Bool = false
    
    @Published var uploadProgress: Double = 0
    @Published var isUploading: Bool = false
    @Published var error: SPError? = nil
        
    private let videoUploadService = VideoUploadService()
    /// AVPlayer used for local video preview playback after selection.
    var player: AVPlayer? = nil
    
    private let trickItemService: TrickItemService
    private let trickItemStore: TrickItemStore
    
    init(
        trickItemService: TrickItemService = .shared,
        trickItemStore: TrickItemStore
    ) {
        self.trickItemService = trickItemService
        self.trickItemStore = trickItemStore
    }
    
    var uploadPossible: Bool {
        !isUploading && !notes.isEmpty && selectedVideoURL != nil
    }

    func cancelUpload() {
        videoUploadService.cancel()
        isUploading = false
    }
    
    /// Validates that the current form state is valid for uploading a trick item and the user's trick item count
    /// is under the limit of 6.
    ///
    /// - Parameters:
    ///   - trickItemCount: The current number of trick items already attached to the trick.
    ///
    /// - Throws: `SPError` if validation fails.
    func validate(trickItemCount: Int) throws {
        guard !notes.isEmpty else {
            throw SPError.custom("Please enter notes.")
        }
        guard (0...3).contains(progress) else {
            throw SPError.custom("Invalid progress rating.")
        }
        
        guard trickItemCount < 6 else {
            throw SPError.custom("Trick items are limitted to 6 per trick. Delete an old trick item if you wish to upload a new one")
        }
    }
    
    /// Compresses and uploads the selected video to remote storage.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user uploading the video.
    ///
    /// - Returns:
    ///   - videoData: Metadata about the uploaded video.
    ///   - trickItemId: The generated ID for the new trick item.
    ///
    /// - Throws: `VideoUploadError` if the video is invalid or missing.
    func compressAndUploadVideo(
        userId: String
    ) async throws -> (videoData: VideoData, trickItemId: String) {
        
        guard
            let videoURL = selectedVideoURL,
            let size = videoSize else
        {
            throw VideoUploadError.invalidVideo
        }
        
        let trickItemId = FirebaseHelpers.generateFirebaseId()
        let storagePath = VideoUploadDestination(
            uploadSource: .trickItem,
            userId: userId,
            fileId: trickItemId
        )
        
        uploadProgress = 0
        defer { uploadProgress = 0 }
        
        videoUploadService.onProgress = { [weak self] progress in
            self?.uploadProgress = progress
        }
        
        let videoData = try await videoUploadService.uploadVideo(
            sourceURL: videoURL,
            size: size,
            storagePath: storagePath
        )
        
        return (videoData, trickItemId)
    }
    
    /// Uploads a complete trick item including video and metadata.
    ///
    /// - Parameters:
    ///   - userId: The ID of the user uploading the trick item.
    ///   - trick: The trick the trick item belongs to.
    ///   - trickItemCount: Current number of items already in the trick (used for validation).
    func uploadTrickItem(
        userId: String,
        trick: Trick,
        trickItemCount: Int
    ) async {
        
        isUploading = true
        defer { isUploading = false }
        
        do {
            try validate(trickItemCount: trickItemCount)
            
            let (videoData, trickItemId) = try await compressAndUploadVideo(userId: userId)
            
            let request = UploadTrickItemRequest(
                id: trickItemId,
                notes: notes,
                progress: progress,
                trickData: TrickData(trick: trick),
                videoData: videoData
            )
            
            let newTrickItem = TrickItem(request: request)
            
            try await trickItemService.uploadTrickItem(trickItem: newTrickItem)
            trickItemStore.addTrickItem(newTrickItem)
            
        } catch {
            self.error = mapToSPError(error: error)
        }
    }

    /// Loads a selected video from PhotosPicker and prepares it for preview playback.
    ///
    /// - Parameters:
    ///   - item: The selected `PhotosPickerItem` containing the video.
    func loadVideo(from item: PhotosPickerItem) {
        Task {
            resetVideoPreview()
            self.loadingVideoPreview = true
            defer { self.loadingVideoPreview = false }

            do {
                (self.selectedVideoURL, self.videoSize) = try await videoUploadService.loadVideo(from: item)
                
                guard let url = selectedVideoURL else {
                    throw SPError.custom("Error, couldnt get video url")
                }
            
                self.player = AVPlayer(url: url)

            } catch {
                resetVideoPreview()
                self.error = mapToSPError(error: error)
            }
        }
    }
    
    /// Resets all video selection and preview state.
    func resetVideoPreview() {
        self.selectedItem = nil
        self.selectedVideoURL = nil
        self.videoSize = nil
        self.player = nil
    }
}
