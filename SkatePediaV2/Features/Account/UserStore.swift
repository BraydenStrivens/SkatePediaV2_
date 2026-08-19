//
//  UserStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation
import FirebaseFirestore


/// Global store responsible for managing the authenticated user's data.
///
/// `UserStore` coordinates:
/// - Real-time user snapshot listening
/// - Published authentication-related UI state
/// - User loading and error handling
/// - Derived user settings and convenience helpers
/// - UI update deduplication for snapshot listeners
///
/// The store listens to live updates from `UserService` and publishes
/// changes to SwiftUI views throughout the application.
@MainActor
final class UserStore: ObservableObject {
    
    // MARK: Published State
    
    @Published private(set) var user: User?
    @Published var isLoading = false
    @Published var blockingError: SPError?
    @Published var error: SPError?
    
    // MARK: Derived Properties
    
    var trickSettings: TrickListSettings? {
        user?.settings.trickSettings
    }
    var profileSettings: ProfileSettings? {
        user?.settings.profileSettings
    }
    var trickListData: TrickListData? {
        user?.trickListData
    }
    
    var favoriteTricks: [String]? {
        user?.favoriteTricks ?? nil
    }
    
    // MARK: Private Properties
    
    /// Cached UI-facing user state used to prevent unnecessary publishes.
    private var lastUIState: UserUIState?
    
    /// Timeout task used to detect stalled user loading operations.
    private var timeoutTask: Task<Void, Never>?
    private let service = UserService.shared
    
    // MARK: Private Models

    /// Lightweight UI-facing representation of user state used for
    /// equality comparisons before publishing updates.
    ///
    /// This helps avoid unnecessary SwiftUI view invalidation when
    /// backend snapshots contain unchanged UI-relevant data.
    private struct UserUIState: Equatable {
        let username: String
        let stance: UserStance
        let bio: String
        let profilePhoto: ProfilePhotoData?
        let favoriteTricks: [String]?
        let settings: UserSettings
        let trickListData: TrickListData
    }
    
    // MARK: Public Actions

    /// Starts listening for real-time updates to the authenticated user.
    ///
    /// This method:
    /// - Begins a live Firestore listener
    /// - Starts a loading timeout watchdog
    /// - Publishes incoming user updates
    /// - Deduplicates unchanged UI state updates
    /// - Updates loading and error state appropriately
    ///
    /// - Parameter uid:
    /// The authenticated Firebase user identifier.
    func startListening(
        uid: String
    ) {
        isLoading = true
        blockingError = nil
        
        startTimeout()
        
        service.listenToUser(userId: uid) { [weak self] result in
            guard let self else { return }
            
            self.timeoutTask?.cancel()
            
            Task { @MainActor in
                switch result {
                case .success(let newUser):
                    self.isLoading = false
                    
                    if self.shouldPublishUpdate(newUser) {
                        print("USER SNAPSHOT RECEIVED")
                        self.user = newUser
                    }
                case .failure(let error):
                    self.isLoading = false
                    self.blockingError = mapToSPError(error: error)
                }
            }
        }
    }
    
    /// Stops listening for authenticated user updates.
    ///
    /// This removes the active Firestore snapshot listener.
    func stopListening() {
        service.removeListener()
    }
    
    /// Starts a timeout watchdog for the initial user loading process.
    ///
    /// If no user snapshot is received within the timeout duration,
    /// a blocking error is presented to the user.
    func resetUnseenNotificationCount() {
        user?.unseenNotificationCount = 0
    }
    
    /// Returns the preferred display name for a trick data object.
    ///
    /// The displayed value respects the user's trick abbreviation settings.
    ///
    /// - Parameter trickData:
    /// The trick data model.
    ///
    /// - Returns:
    /// The localized/display-ready trick name.
    func getTrickName(
        _ trickData: TrickData
    ) -> String {
        return trickSettings?.useTrickAbbreviations == true
            ? trickData.abbreviatedName
            : trickData.name
    }
    
    /// Returns the preferred display name for a trick.
    ///
    /// The displayed value respects:
    /// - User abbreviation settings
    /// - Custom trick naming overrides
    ///
    /// - Parameter trick:
    /// The trick model.
    ///
    /// - Returns:
    /// The localized/display-ready trick name.
    func getTrickName(
        _ trick: Trick
    ) -> String {
        if
            let name = trick.customName,
            let abbreviation = trick.customAbbreviation
        {
            return trickSettings?.useTrickAbbreviations == true
                ? abbreviation
                : name

        } else {
            return trickSettings?.useTrickAbbreviations == true
                ? trick.abbreviation
                : trick.name
        }
    }
    
    /// Determines whether a trick is currently favorited by the user.
    ///
    /// - Parameter trickId:
    /// The trick identifier.
    ///
    /// - Returns:
    /// `true` if the trick is favorited.
    func isFavoriteTrick(
        _ trickId: String
    ) -> Bool {
        favoriteTricks?.contains(trickId) == true
    }
    
    /// Toggles a trick's favorite state locally.
    ///
    /// If the trick already exists in favorites it is removed;
    /// otherwise it is added.
    ///
    /// - Parameter trickId:
    /// The trick identifier.
    func toggleFavorite(
        trickId: String
    ) {
        var updated = favoriteTricks ?? []
        
        if updated.contains(trickId) {
            updated.removeAll { $0 == trickId }
            
        } else {
            updated.append(trickId)
        }
    }
    
    // MARK: Private Helpers
    
    /// Determines whether an incoming user snapshot should trigger a UI update.
    ///
    /// This method compares a lightweight UI-facing representation of
    /// the new user against the previously published state.
    ///
    /// - Parameter newUser:
    /// The newly received user snapshot.
    ///
    /// - Returns:
    /// `true` if the UI should publish the update.
    private func shouldPublishUpdate(
        _ newUser: User
    ) -> Bool {
        let newState = UserUIState(
            username: newUser.username,
            stance: newUser.stance,
            bio: newUser.bio,
            profilePhoto: newUser.profilePhoto,
            favoriteTricks: newUser.favoriteTricks,
            settings: newUser.settings,
            trickListData: newUser.trickListData
        )
        
        defer { lastUIState = newState }
        
        return newState != lastUIState
    }
    
    /// Starts a timeout watchdog for the initial user loading process.
    ///
    /// If no user snapshot is received within the timeout duration,
    /// a blocking error is presented to the user.
    private func startTimeout() {
        timeoutTask?.cancel()
        
        timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 15_000_000_000)
            
            if !Task.isCancelled {
                await MainActor.run {
                    if self.user == nil {
                        self.isLoading = false
                        self.blockingError = SPError.custom("Failed to load account. Please logout and log back in.")
                    }
                }
            }
        }
    }
}
