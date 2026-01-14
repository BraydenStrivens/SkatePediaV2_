//
//  TrickListViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import Combine

/// Manages the data fetched or updated from the user's trick list collection. Contains functions for
/// fetching the users trick list and trick list data and functions for hiding and deleting tricks.
///
@MainActor
final class TrickListViewModel: ObservableObject {
    @Published var user: User = .emptyStruct
    @Published var trickListInfo: TrickListInfo = .emptyStruct
    
    // Trick lists by stance that will be sorted by difficutly
    @Published var regularTrickList: [[Trick]] = []
    @Published var fakieTrickList: [[Trick]] = []
    @Published var switchTrickList: [[Trick]] = []
    @Published var nollieTrickList: [[Trick]] = []
        
    @Published var getTrickListFetchState: RequestState = .idle
    @Published var error: FirestoreError? = nil
    
    init() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.getTrickListFetchState = .failure(SPError.unknown)
            return
        }
        
        if case .idle = getTrickListFetchState {
            Task {
                await loadTrickListView(userId: uid)
            }
        }
    }
    
    /// Fetches the current user's information, the user's trick list info, and all of the tricks in the user's trick list. Validates the fetched data
    /// and handles errors accordingly.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///
    func loadTrickListView(userId: String) async {
        do {
            self.getTrickListFetchState = .loading
            
            if self.user == .emptyStruct {
                self.user = try await UserManager.shared.fetchUser(withUid: userId) ?? .emptyStruct
            }
            try await fetchTrickListInfo(userId: userId)
            try await fetchUserTrickLists(userId: userId)
            
            try validateFetch()

            self.getTrickListFetchState = .success
            
        } catch let error as FirestoreError {
            self.getTrickListFetchState = .failure(.firestore(error))
            
        } catch {
            self.getTrickListFetchState = .failure(.unknown)
        }
    }
    
    /// Fetches the user's trick list information.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///
    /// - Throws: An error returned from firebase specifying the cause of the failed request.
    ///
    private func fetchTrickListInfo(userId: String) async throws {
        do {
            self.trickListInfo = try await TrickListInfoManager.shared.fetchTrickListInfo(userId: userId)
        } catch {
            throw error
        }
    }
    
    /// Fetches the user's trick list and stores them by stance.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///
    /// - Throws: An error returned from firebase specifying the cause of the failed request.
    ///
    private func fetchUserTrickLists(userId: String) async throws {
        do {
            self.regularTrickList = try await fetchAndSortTrickListByStance(userId: userId, stance: Stance.Stances.regular.rawValue)
                        
            self.fakieTrickList = try await fetchAndSortTrickListByStance(userId: userId, stance: Stance.Stances.fakie.rawValue)
            
            self.switchTrickList = try await fetchAndSortTrickListByStance(userId: userId, stance: Stance.Stances._switch.rawValue)
            
            self.nollieTrickList = try await fetchAndSortTrickListByStance(userId: userId, stance: Stance.Stances.nollie.rawValue)
        } catch {
            throw error
        }
    }
    
    /// Fetches the tricks for a given stance from the user's trick list.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - stance: The stance of the tricks to be fetched.
    ///
    /// - Throws: An error returned from firebase specifying the cause of the failed request.
    ///
    private func fetchAndSortTrickListByStance(userId: String, stance: String) async throws -> [[Trick]] {
        do {
            let trickList = try await TrickListManager.shared.fetchTricksByStance(userId: userId, stance: stance)
            
            let sortedTrickList = TrickListManager.shared.sortTrickListByDifficulty(unsortedTrickList: trickList)
            
            return sortedTrickList
            
        } catch {
            throw error
        }
    }
    
    /// Validates that the current user and their trick list info was successfully fetched.
    ///
    /// - Throws: A custom error that specifyies the data that failed to be fetched.
    ///
    private func validateFetch() throws {
        if user == .emptyStruct {
            throw FirestoreError.custom("Failed to fetch current user.")
        }
        if trickListInfo == .emptyStruct {
            throw FirestoreError.custom("Failed to fetch trick list information.")
        }
    }
    
    /// Sets a trick to 'hidden' in the trick's document in the user's trick list collection. Re-fetches the user's trick data and trick list
    /// upon success. Handles errors accordingly.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - trick: A 'Trick' object containing information about the trick to be hidden.
    ///
    func hideTrick(userId: String, trick: Trick) async {
        do {
            try await TrickListManager.shared.hideTrick(userId: userId, trick: trick)

            // Re-fetch trick list to update the view
            await loadTrickListView(userId: userId)
            
        } catch let error as FirestoreError {
            self.error = error
            
        } catch {
            self.error = FirestoreError.unknown
        }
    }
    
    /// Resets the 'hidden' attribute to false for each trick in a given stance. Handles errors accordingly.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - stance: The stance corresponding to the list of tricks to reset.
    ///
    func resetHiddenTricks(userId: String, stance: String) async {
        do {
            try await TrickListManager.shared.resetHiddenTricks(userId: userId, stance: stance)
            
            // Re-fetch trick list to update the view
            await loadTrickListView(userId: userId)
            
        } catch let error as FirestoreError {
            self.error = error
            
        } catch {
            self.error = FirestoreError.unknown
        }
    }
    
    /// Deletes a trick's document from the user's trick list collection. Re-fetches the user's trick data and trick list
    /// upon success. Handles errors accordingly.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - trick: A 'Trick' object containing information about the trick to be deleted.
    ///
    func deleteTrick(userId: String, trick: Trick) async {
        do {
            try await TrickListManager.shared.deleteTrick(userId: userId, trick: trick)
            
            // Re-fetch trick list to update the view
            await loadTrickListView(userId: userId)
            
        } catch let error as FirestoreError {
            self.error = error
            
        } catch {
            self.error = FirestoreError.unknown
        }
    }
}
