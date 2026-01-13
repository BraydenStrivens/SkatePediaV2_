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

@MainActor
final class TrickListViewModel: ObservableObject {
    
    @Published var user: User = .emptyStruct
    @Published var trickListInfo: TrickListInfo = .emptyStruct
    
    @Published var regularTrickList: [[Trick]] = []
    @Published var fakieTrickList: [[Trick]] = []
    @Published var switchTrickList: [[Trick]] = []
    @Published var nollieTrickList: [[Trick]] = []
        
    @Published var getTrickListFetchState: RequestState = .idle
    @Published var deleteTrickState: RequestState = .idle
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
    
    func loadTrickListView(userId: String) async {
        do {
            self.getTrickListFetchState = .loading
            
            if self.user == .emptyStruct {
                self.user = try await UserManager.shared.fetchUser(withUid: userId) ?? .emptyStruct
            }
            
            try await fetchTrickListInfo(userId: userId)
            try await fetchUserTrickLists(userId: userId)
            
            if fetchFailed() {
                throw FirestoreError.unknown
            }

            self.getTrickListFetchState = .success
            
        } catch let error as FirestoreError {
            self.getTrickListFetchState = .failure(.firestore(error))
            
        } catch {
            self.getTrickListFetchState = .failure(.unknown)
        }
    }
    
    func fetchTrickListInfo(userId: String) async throws {
        do {
            self.trickListInfo = try await TrickListInfoManager.shared.fetchTrickListInfo(userId: userId)
        } catch {
            throw error
        }
    }
    
    func fetchUserTrickLists(userId: String) async throws {
        do {
            self.regularTrickList = try await fetchAndSortTrickListByStance(userId: userId, stance: Stance.Stances.regular.rawValue)
            
            self.fakieTrickList = try await fetchAndSortTrickListByStance(userId: userId, stance: Stance.Stances.fakie.rawValue)
            
            self.switchTrickList = try await fetchAndSortTrickListByStance(userId: userId, stance: Stance.Stances._switch.rawValue)
            
            self.nollieTrickList = try await fetchAndSortTrickListByStance(userId: userId, stance: Stance.Stances.nollie.rawValue)
        } catch {
            throw error
        }
    }
    
    func fetchAndSortTrickListByStance(userId: String, stance: String) async throws -> [[Trick]] {
        do {
            let trickList = try await TrickListManager.shared.fetchTricksByStance(userId: userId, stance: stance)
            
            let sortedTrickList = TrickListManager.shared.sortTrickListByDifficulty(unsortedTrickList: trickList)
            
            return sortedTrickList
            
        } catch {
            throw FirestoreError.mapFirebaseError(error)
        }
    }
    
    private func fetchFailed() -> Bool {
        if user == .emptyStruct { return true }
        if trickListInfo == .emptyStruct { return true }
        if regularTrickList[0].isEmpty { return true }
        if fakieTrickList[0].isEmpty { return true }
        if switchTrickList[0].isEmpty { return true }
        if nollieTrickList[0].isEmpty { return true }
        
        return false
    }
    
    func addTrick() async {
        
    }
    
    func deleteTrick(userId: String, trick: Trick) async {
        do {
            deleteTrickState = .loading
            
            try await TrickListManager.shared
                .deleteTrick(userId: userId,trick: trick)
            
            deleteTrickState = .success
            
            // Re-fetch trick list to update the view
            await loadTrickListView(userId: userId)
            
        } catch let error as FirestoreError {
            deleteTrickState = .failure(.firestore(error))
            
        } catch {
            deleteTrickState = .failure(.unknown)
        }
    }
}
