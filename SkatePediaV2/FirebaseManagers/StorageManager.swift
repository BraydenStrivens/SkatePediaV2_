//
//  StorageManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import Firebase
import FirebaseStorage

/// Contains functions for uploading to and fetching from the databases storage.
final class StorageManager {
    static let shared = StorageManager()
    private init() { }
    
    private let proVideoCollection = Storage.storage().reference().child("pro_videos/")
    private let trickItemVideoCollection = Storage.storage().reference().child("user_videos/")
    private let profilePhotoCollection = Storage.storage().reference().child("profile_photos")
    private let communityPostVideoCollection = Storage.storage().reference().child("community_post_videos/")
    private let directMessageFileCollection = Storage.storage().reference().child("direct_message_files/")
    
    private func getProVideoCollection(proId: String) -> StorageReference {
        proVideoCollection.child("\(proId)")
    }
    
    func uploadImage(_ image: UIImage, userId: String) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.25) else { return nil }
        
        let storageRef = profilePhotoCollection.child(userId)
        
        // Deletes existing profile image
        storageRef.getMetadata() { (metadata: StorageMetadata?, error) in
            if error != nil { return }
            
            guard let metadata = metadata else { return}
            
            // Checks if profile image already exists
            if metadata.isFile {
                Task {
                    try await storageRef.delete()
                }
            }
        }
        
        do {
            let _ = try await storageRef.putDataAsync(imageData)
            let url = try await storageRef.downloadURL()
            return url.absoluteString
            
        } catch {
            print("DEBUG: Failed to upload image with error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Uploads the video for a specified trick item to storage. Returns the video url of the uploaded video which is used to play the video
    /// in the video player. The name of this video in storage is the trick item's id.
    ///
    /// - Parameters:
    ///  - videoData: Data about the trick item video.
    ///  - trickItemId: The id of the trick item in the database.
    ///
    /// - Returns: The video url of the trick item's video in storage.
    func uploadTrickItemVideo(videoData: Data, trickItemId: String) async throws -> String? {
        // Creates a reference to the trick item in storage
        let ref = trickItemVideoCollection.child("\(trickItemId)")
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        do {
            // Uploads data about the video to the database
            let _ = try await ref.putDataAsync(videoData, metadata: metadata)
            // Gets the video's video url
            let url = try await ref.downloadURL()
            
            print("DEBUG: TRICK ITEM VIDEO SUCCESSFULLY UPLOADED TO STORAGE")
            return url.absoluteString
        } catch {
            print("DEBUG: FAILED TO UPLOAD TRICK ITEM VIDEO TO STORAGE")
            return nil
        }
    }
    
    /// Deletes the video associated with a trick item from storage. The name of the video in storage is the trick item's id.
    ///
    /// - Parameters:
    ///  - trickItemId: The id of the trick item in storage.
    func deleteTrickItemVideo(trickItemId: String) async throws {
        let postRef = trickItemVideoCollection.child("\(trickItemId)")
        
        do {
            try await postRef.delete()
        } catch {
            print("DEBUG: TRICK ITEM VIDEO COULD NOT BE DELETED, \(error)")
        }
    }
    
    /// Uploads video associated with a post to storage. The name of the video is the post's id.
    ///
    /// - Parameters:
    ///  - videoData: Data about the post's video.
    ///  - postId: The id of the post in the database.
    ///
    /// - Returns: The video url of the post's video in storage.
    func uploadPostVideo(videoData: Data, postId: String) async throws -> String? {
        let filename = postId
        let ref = communityPostVideoCollection.child("\(filename)")
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        do {
            let _ = try await ref.putDataAsync(videoData, metadata: metadata)
            let url = try await ref.downloadURL()
            
            print("DEBUG: TRICK ITEM VIDEO SUCCESSFULLY UPLOADED TO STORAGE")
            return url.absoluteString
        } catch {
            print("DEBUG: FAILED TO UPLOAD TRICK ITEM VIDEO TO STORAGE")
            return nil
        }
    }
    
    /// Deletes the video associated with a post from storage. The name of this video in storage is the post's id.
    ///
    /// - Parameters:
    ///  - postId: The id of a post in storage.
    func deletePostVideo(postId: String) async throws {
        let postRef = communityPostVideoCollection.child("\(postId)")
        
        do {
            try await postRef.delete()
        } catch {
            print("DEBUG: POST VIDEO COULD NOT BE DELETED, \(error)")
        }
    }
    
    /// Uploads video associated with a post to storage. The name of the video is the post's id.
    ///
    /// - Parameters:
    ///  - videoData: Data about the post's video.
    ///  - postId: The id of the post in the database.
    ///
    /// - Returns: The video url of the post's video in storage.
    func uploadDirectMessageFile(fileData: Data, messageId: String) async throws -> String? {
        let filename = messageId
        let ref = directMessageFileCollection.child("\(filename)")
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        do {
            let _ = try await ref.putDataAsync(fileData, metadata: metadata)
            let url = try await ref.downloadURL()
            
            print("DEBUG: TRICK ITEM VIDEO SUCCESSFULLY UPLOADED TO STORAGE")
            return url.absoluteString
        } catch {
            print("DEBUG: FAILED TO UPLOAD TRICK ITEM VIDEO TO STORAGE")
            return nil
        }
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
