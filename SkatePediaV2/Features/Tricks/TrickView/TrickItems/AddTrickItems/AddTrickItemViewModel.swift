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
    var player: AVPlayer? = nil
    
    private let useCases: TrickItemUseCases
    
    init(useCases: TrickItemUseCases) {
        self.useCases = useCases
    }
    
    var uploadPossible: Bool {
        !isUploading && !notes.isEmpty && selectedVideoURL != nil
    }

    func cancelUpload() {
        videoUploadService.cancel()
        isUploading = false
    }
    
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
    
    func compressAndUploadVideo(
        userId: String
    ) async throws -> (videoData: VideoData, trickItemId: String) {
        
        guard
            let videoURL = selectedVideoURL,
            let size = videoSize else
        {
            throw VideoUploadError.invalidVideo
        }
        
        let trickItemId = Firestore.firestore().collection("trick_items").document().documentID
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
            
            try await useCases.upload(request)
            
        } catch {
            self.error = mapToSPError(error: error)
        }
    }

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
    
    func resetVideoPreview() {
        self.selectedItem = nil
        self.selectedVideoURL = nil
        self.videoSize = nil
        self.player = nil
    }
}
