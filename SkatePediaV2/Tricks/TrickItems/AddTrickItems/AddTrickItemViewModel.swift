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

final class AddTrickItemViewModel: ObservableObject {
    
    @Published var notes: String = ""
    @Published var progress: Int = 0
    @Published var errorMessage = ""
    @Published var selectedAVideo = false
    @Published var loadState = LoadState.unknown
    @Published var selectedItem: PhotosPickerItem?
    @Published var trickItemUploadState: RequestState = .idle
    
    var previewThumbnail: UIImage? = nil

    enum LoadState {
        case unknown, loading, loaded(PreviewVideo), failed
    }
    
    @MainActor
    func generateThumbnail(previewVideo: AVPlayer) {
        Task.detached {
            guard let asset = await previewVideo.currentItem?.asset else { return }
            
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            // Min size
            generator.maximumSize = .init(width: 250, height: 250)
            
            do {
                let totalDuration = try await asset.load(.duration).seconds
                
                let time = CMTime(seconds: totalDuration * 0.5, preferredTimescale: 600)
                
                let result = try await generator.image(at: time)
                let cgImage = result.image
                
                DispatchQueue.main.async {
                    self.previewThumbnail = UIImage(cgImage: cgImage)
                }

            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func validateInput() -> Bool {
        return !notes.isEmpty && selectedItem != nil
    }
    
    /// Uploads a trick item to the database and storage.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - data: A 'JsonTrick' object containing information about the trick the trick item is for.
    @MainActor
    func addTrickItem(userId: String, trick: Trick) async -> TrickItem? {
        do {
            self.trickItemUploadState = .loading
            
            guard let item = selectedItem else {
                throw FirestoreError.unknown
            }
            guard let videoData = try await item.loadTransferable(type: Data.self) else {
                throw FirestoreError.unknown
            }
            
            let trickItem = TrickItem(
                id: "",
                trickId: trick.id,
                trickName: trick.name,
                dateCreated: Date(),
                stance: trick.stance,
                notes: notes,
                progress: progress,
                videoData: VideoData(videoUrl: "", width: 0, height: 0)
            )
                        
            let newTrickItem = try await TrickItemManager.shared.uploadTrickItem(userId: userId, videoData: videoData, trickItem: trickItem)
            
            self.trickItemUploadState = .success
            return newTrickItem
            
        } catch let error as FirestoreError {
            self.trickItemUploadState = .failure(.firestore(error))
            return nil
            
        } catch {
            self.trickItemUploadState = .failure(.unknown)
            return nil
        }
    }
}
