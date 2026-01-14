//
//  PreviewObjects.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/21/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

public class PreviewObjects {
    static let user = User(userId: NSUUID().uuidString, email: "preview@gmail.com", username: "Preview User", stance: "Goofy", dateCreated: Date())
    
//    static let notification = Notification(id: NSUUID().uuidString, fromUserId: NSUUID().uuidString, toUserId: NSUUID().uuidString, notificationType: .comment, dateCreated: Timestamp(), seen: false)
    
//    static let message = Message(id: NSUUID().uuidString, fromUserId: NSUUID().uuidString, toUserId: NSUUID().uuidString, content: "Yo what up bro. You got dope tre flips", videoUrl: "", dateCreated: Timestamp())
    
//    static let trick = Trick(id: NSUUID().uuidString, name: "Backside Kickflip", stance: "Regular", abbreviation: "BS Flip", learnFirst: "Backside 180, Kickflip", learnFirstAbbreviation: "BS 180, Kickflip", difficulty: "Intermediate", learned: false, inProgress: true)
    
//    static let trickItem = TrickItem(id: NSUUID().uuidString, trickId: NSUUID().uuidString, trickName: "Ollie", dateCreated: Date(), stance: "Switch", notes: "Needs work", progress: 1, videoUrl: "")
    
//    static let post = Post(postId: NSUUID().uuidString, ownerId: NSUUID().uuidString, trickId: NSUUID().uuidString, content: "Anyone got any tips?", commentCount: 2, dateCreated: Timestamp(), videoUrl: "")
    
//    static let comment = Comment(commentId: NSUUID().uuidString, postId: NSUUID().uuidString, commenterUid: NSUUID().uuidString, replyCount: 2, isReply: false, baseId: NSUUID().uuidString, content: "Yo u gotta lean back more", dateCreated: Timestamp())
    
    func fetchCurrentUser() -> User? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }

        Task {
            return try await UserManager.shared.fetchUser(withUid: uid)
        }
        return nil
    }
}
