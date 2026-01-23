//
//  AddPostViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import Foundation
import PhotosUI
import AVKit
import SwiftUI
import Firebase
import FirebaseAuth

/// Contains data related to the new post being uploaded and a function to upload the post.
///
final class AddPostViewModel: ObservableObject {
    @Published var content: String = ""
    /// Saves the old content if the user selects useTrickItemNotes. Gets reset as the content if the user unselects useTrickItemNotes.
    @Published var oldContent: String = ""
    @Published var useTrickItemNotes: Bool = false
    @Published var showProgress: Bool = true
    @Published var isUploading: Bool = false
    @Published var error: SPError? = nil
    @Published var newPost: Post? = nil
    

    /// Uploads a new post to the database. Sets the newPost variable on success which is appended to the community view models posts array in the view.
    ///
    /// - Parameters:
    ///  - user: A 'User' object containing information about the current user.
    ///  - trick: A 'Trick' object containing information about the trick for which the trick item is uploaded for.
    ///  - trickItem: A 'TrickItem' object containing information about the trick item the post is based on.
    ///  
    @MainActor
    func uploadPost(user: User, trick: Trick, trickItem: TrickItem) async {
        do {
            self.isUploading = true
            
            let postData: [String : Any] = [
                Post.CodingKeys.content.rawValue : content,
                Post.CodingKeys.showTrickItemRating.rawValue : showProgress
            ]
            
            self.newPost = try await PostManager.shared.uploadPost(
                postData: postData,
                user: user,
                trick: trick,
                trickItem: trickItem
            )
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
        self.isUploading = false
    }
}
