//
//  UserService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

/// Service responsible for all user-related Firestore operations.
///
/// `UserService` coordinates:
/// - Fetching user documents
/// - Real-time user snapshot listeners
/// - Updating user profile/settings data
/// - Managing favorite tricks and notification state
/// - Managing user friendships and friend requests
/// - Performing user-related Firestore batch operations
///
/// This service acts as the single source of truth for all
/// backend communication involving `User` and `Friend` models.
///
/// Architecture:
/// `UserService` is implemented as a shared singleton because:
/// - Firestore listeners must be centrally managed
/// - User data access is globally required throughout the app
/// - Shared listener lifecycle simplifies synchronization
///
/// UI-facing state updates should instead occur within stores
/// or view models that consume this service.
final class UserService {
    
    // MARK: Shared Instance
    static let shared = UserService()
    private init() {}
    
    // MARK: Private Properties
    private var userListener: ListenerRegistration?
    private let functions = Functions.functions()
    
    // MARK: Firestore References
    
    private let usersCollection = Firestore.firestore()
        .collection("users")
    
    /// Returns the Firestore document reference for a user.
    ///
    /// - Parameter userId:
    /// The user identifier.
    ///
    /// - Returns:
    /// A Firestore document reference.
    private func userRef(
        _ userId: String
    ) -> DocumentReference {
        usersCollection.document(userId)
    }
    
    // MARK: Real-Time Listeners

    /// Starts listening for real-time updates to a user document.
    ///
    /// This method:
    /// - Attaches a Firestore snapshot listener
    /// - Decodes incoming snapshots into `User`
    /// - Emits decoded updates through the provided callback
    /// - Emits failures for missing users or decoding errors
    ///
    /// - Parameters:
    ///   - userId: The user identifier to observe.
    ///   - onChange: Callback invoked whenever the user changes.
    func listenToUser(
        userId: String,
        onChange: @escaping (Result<User, Error>) -> Void
    ) {
        userListener = userRef(userId).addSnapshotListener({ snapshot, error in
            if let error {
                onChange(.failure(error))
                return
            }
            
            guard let snapshot, snapshot.exists else {
                onChange(.failure(AuthError.userNotFound))
                return
            }
            
            do {
                let user = try snapshot.data(as: User.self)
                onChange(.success(user))
            } catch {
                onChange(.failure(mapToSPError(error: error)))
            }
        })
    }
    
    /// Removes the active authenticated user listener.
    func removeListener() {
        userListener?.remove()
        userListener = nil
    }
    
    // MARK: User Fetching

    /// Fetches a user document by identifier.
    ///
    /// - Parameter userId:
    /// The user identifier.
    ///
    /// - Returns:
    /// The decoded user model.
    ///
    /// - Throws:
    /// Any Firestore or decoding error encountered.
    func fetchUser(
        userId: String
    ) async throws -> User {
        return try await userRef(userId)
            .getDocument(as: User.self)
    }
    
    /// Searches users by username prefix.
    ///
    /// This method performs a case-insensitive Firestore prefix query
    /// using a normalized lowercase username field.
    ///
    /// Supports cursor-based pagination.
    ///
    /// - Parameters:
    ///   - searchString: The username search query.
    ///   - count: Maximum number of users to return.
    ///   - lastDocument: Pagination cursor document.
    ///
    /// - Returns:
    /// A tuple containing:
    /// - Matching users
    /// - The final Firestore snapshot for pagination
    ///
    /// - Throws:
    /// Any Firestore or decoding error encountered.
    func fetchUserByUsername(
        searchString: String,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [User], lastDocument: DocumentSnapshot?) {
        
        let lowercased = searchString.lowercased()
        
        return try await usersCollection
            .order(by: User.CodingKeys.usernameLowercase.rawValue)
            .start(at: [lowercased])
            .end(at: [lowercased + "\u{f8ff}"])
            .startOptionally(afterDocument: lastDocument)
            .limit(to: count)
            .getDocumentsWithSnapshot(as: User.self)
    }
    
    // MARK: User Updates

    /// Fully replaces a user's Firestore document.
    ///
    /// - Parameter updatedUser:
    /// The updated user model.
    ///
    /// - Throws:
    /// Any Firestore encoding or write error encountered.
    func updateUser(
        updatedUser: User
    ) throws {
        try userRef(updatedUser.userId)
            .setData(from: updatedUser, merge: false)
    }
    
    /// Updates a user's favorite tricks array.
    ///
    /// - Parameters:
    ///   - updatedArray: The updated favorite trick identifiers.
    ///   - userId: The user identifier.
    ///
    /// - Throws:
    /// Any Firestore update error encountered.
    func updateUserFavoriteTricks(
        updatedArray: [String],
        for userId: String
    ) async throws {
        try await userRef(userId)
            .updateData(
                [ User.CodingKeys.favoriteTricks.rawValue : updatedArray ]
            )
    }
    
    /// Updates a user's settings object.
    ///
    /// - Parameters:
    ///   - newSettings: The updated user settings.
    ///   - userId: The user identifier.
    ///
    /// - Throws:
    /// Any Firestore update error encountered.
    func updateUserSettings(
        _ newSettings: UserSettings,
        for userId: String
    ) async throws {
        try await userRef(userId)
            .updateData(
                [ User.CodingKeys.settings.rawValue: newSettings.asDictionary() ]
            )
    }
    
    /// Resets a user's unseen notification count.
    ///
    /// - Parameter userId:
    /// The user identifier.
    ///
    /// - Throws:
    /// Any Firestore update error encountered.
    func updateUserUnseenNotificationCount(
        for userId: String
    ) async throws {
        try await userRef(userId)
            .updateData(
                [ User.CodingKeys.unseenNotificationCount.rawValue: 0 ]
            )
    }
    
    /// Marks a user account as pending deletion.
    ///
    /// - Parameter userId:
    /// The user identifier.
    ///
    /// - Throws:
    /// Any Firestore update error encountered.
    ///
    /// - Important:
    /// A firebase cloud function handles the actual deletion of all user documents.
    func markUserAsPendingDeletion(
        for userId: String
    ) async throws {
        try await userRef(userId)
            .updateData(
                [ User.CodingKeys.pendingDeletion.rawValue: true ]
            )
    }
}
