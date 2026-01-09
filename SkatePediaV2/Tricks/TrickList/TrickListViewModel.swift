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
        
    @Published var requestState: RequestState = .idle
    @Published var error: FirestoreError? = nil
    
    init() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.requestState = .failure(FirestoreError.unknown)
            return
        }
        
        Task {
            try await loadTrickListView(userId: uid)
        }
    }
    
    func loadTrickListView(userId: String) async throws {
        do {
            self.requestState = .loading
            
            if self.user == .emptyStruct {
                self.user = try await UserManager.shared.fetchUser(withUid: userId) ?? .emptyStruct
            }
            
            try await fetchTrickListInfo(userId: userId)
            try await fetchUserTrickLists(userId: userId)
            
            if fetchFailed() {
                throw FirestoreError.unknown
            }

            self.requestState = .success
            
        } catch let error as FirestoreError {
            self.requestState = .failure(error)
            
        } catch {
            self.requestState = .failure(.unknown)
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
    
    func fetchTrickListInfo(userId: String) async throws {
        do {
            self.trickListInfo = try await TrickListInfoManager.shared.fetchTrickListInfo(userId: userId)
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
}
