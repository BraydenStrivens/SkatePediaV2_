//
//  StorageManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ImageData: Codable, Identifiable, Hashable {
    let imageUrl: String
    let storagePath: String
    var id: String { self.storagePath }
}

/// Contains functions for uploading to and fetching from the databases storage.
final class StorageManager {
    static let shared = StorageManager()
    private init() { }
    
    private var uploadTask: StorageUploadTask?
    
    private let proVideoCollection = Storage.storage().reference().child("pro_videos/")
    private let trickItemVideoCollection = Storage.storage().reference().child("user_videos/")
    private let profilePhotoCollection = Storage.storage().reference().child("profile_photos")
    private let directMessageFileCollection = Storage.storage().reference().child("direct_message_files/")
    
    private func getProVideoCollection(proId: String) -> StorageReference {
        proVideoCollection.child("\(proId)")
    }
    
    func generateFileId() -> String {
        return Firestore.firestore().collection("aldkfj;alskdj").document().documentID
    }
    
    func uploadProfilePhoto(_ image: UIImage, userId: String) async throws -> ProfilePhotoData {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw SPError.unknown
        }
        
        let imageId = generateFileId()
        let storagePath = "user_profile_photos/\(userId)/\(imageId).jpg"
        
        do {
            let storageRef = Storage.storage().reference(withPath: storagePath)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            metadata.cacheControl = "public, max-age=604800, immutable"
            
            let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            let url = try await storageRef.downloadURL()
            let imageUrl = url.absoluteString
            
            return ProfilePhotoData(
                imageId: imageId,
                photoUrl: imageUrl,
                storagePath: storagePath,
                lastUpdated: Date()
            )
            
        } catch {
            print("DEBUG: Failed to upload image with error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func uploadVideo(
        url: URL,
        storagePath: VideoUploadDestination,
        onProgress: @escaping (Double) -> Void
    ) async throws -> (downloadURL: URL, path: String) {
        
        let path = storagePath.fullPath
        let ref = Storage.storage().reference(withPath: path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        metadata.cacheControl = "private, max-age=0, no-store"
        
        return try await withCheckedThrowingContinuation { continuation in
            uploadTask = ref.putFile(from: url, metadata: metadata)
            
            uploadTask?.observe(.progress) { snapshot in
                let progress = snapshot.progress?.fractionCompleted ?? 0
                onProgress(progress)
            }
            
            uploadTask?.observe(.success) { _ in
                ref.downloadURL { url, error in
                    if let url = url {
                        continuation.resume(returning: (url, path))
                        
                    } else {
                        continuation.resume(
                            throwing: error ?? VideoUploadError.uploadFailed
                        )
                    }
                }
            }
            
            uploadTask?.observe(.failure) { snapshot in
                let error = snapshot.error as NSError?
                
                if error?.code == StorageErrorCode.cancelled.rawValue {
                    continuation.resume(throwing: CancellationError())
                    
                } else {
                    continuation.resume(throwing: VideoUploadError.uploadFailed)
                }
            }
        }
    }
    
    func cancelUpload() {
        uploadTask?.cancel()
    }
    
    /// Deletes the video associated with a trick item from storage. The name of the video in storage is the trick item's id.
    ///
    /// - Parameters:
    ///  - trickItemId: The id of the trick item in storage.
    func deleteTrickItemVideo(path: String) async throws {
        let trickItemVideoRef = Storage.storage().reference(withPath: path)
        
        do {
            try await trickItemVideoRef.delete()
        } catch {
            print("DEBUG: TRICK ITEM VIDEO COULD NOT BE DELETED, \(error)")
            throw error
        }
    }
    
    func uploadDirectMessageVideo(videoUrl: URL, messageId: String) async throws -> String {
        let filename = messageId
        let ref = directMessageFileCollection.child("\(filename)")
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        let _ = try await ref.putFileAsync(from: videoUrl, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    func uploadDirectMessagePhoto(photoData: Data, messageId: String) async throws -> String {
        let filename = messageId
        let ref = directMessageFileCollection.child("\(filename)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await ref.putDataAsync(photoData, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    /// Deletes the video associated with a post from storage. The name of this video in storage is the post's id.
    ///
    /// - Parameters:
    ///  - postId: The id of a post in storage.
    func deleteMessageFile(messageId: String) async throws {
        let postRef = directMessageFileCollection.child("\(messageId)")
        
        do {
            try await postRef.delete()
        } catch {
            print("DEBUG: POST VIDEO COULD NOT BE DELETED, \(error)")
        }
    }
    
    /// Gets the video url associated with a video in the 'pro_videos' storage folder. This url is used to play the video in a video player.
    /// The pro's id is the name of the folder in storage and the trick''s id is the name of the video file.
    ///
    /// - Parameters:
    ///  - proId: The id of a pro in the database.
    ///  - trickId: The id of a trick in the database.
    ///
    /// - Returns: The video url of the specified pro and specific trick's video in storage.
    func getProVideoUrl(proId: String, trickId: String) async throws -> String {
        let ref = getProVideoCollection(proId: proId).child("\(trickId).mp4")
        
        print("DEBUG: REF = \(ref)")
        do {
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("DEBUG: COULDNT GET PRO VIDEO URL")
            return "N/A"
        }
    }
}
