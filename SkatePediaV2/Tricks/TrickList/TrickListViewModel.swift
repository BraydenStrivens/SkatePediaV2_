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
    
    @Published var user: User? = nil
    @Published var trickListInfo: TrickListInfo? = nil
    
    @Published var regularTrickList: [[Trick]] = []
    @Published var fakieTrickList: [[Trick]] = []
    @Published var switchTrickList: [[Trick]] = []
    @Published var nollieTrickList: [[Trick]] = []
    
    @Published private var cancellables = Set<AnyCancellable>()
    @Published var fetched: Bool = false
    @Published var failedToFetch: Bool = false
    
    init() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                if self.user == nil { self.user = try await UserManager.shared.fetchUser(withUid: uid) }
                addListenerForAllTrickLists()
                
                self.failedToFetch = validateFetch()
            } catch {
                print("ERROR FETCHING TRICK LIST: \(error)")
            }
        }
    }
    
    private func validateFetch() -> Bool {
        if trickListInfo == nil { return true }
        if regularTrickList.isEmpty { return true }
        if fakieTrickList.isEmpty { return true }
        if switchTrickList.isEmpty { return true }
        if nollieTrickList.isEmpty { return true }

        return false
    }
    
    private func addListenerForAllTrickLists() {
        if let user = user {
            self.fetched = false
            addListenerForTrickListInfo(userId: user.userId)
            
            addListenerForTrickList(userId: user.userId, stance: Stance.Stances.regular.rawValue)
            addListenerForTrickList(userId: user.userId, stance: Stance.Stances.fakie.rawValue)
            addListenerForTrickList(userId: user.userId, stance: Stance.Stances._switch.rawValue)
            addListenerForTrickList(userId: user.userId, stance: Stance.Stances.nollie.rawValue)
            self.fetched = true
        } else {
            print("Couldnt fetch user")
        }
    }
    
    func addListenerForTrickList(userId: String, stance: String) {
        TrickListManager.shared.addListenerForTrickList(userId: userId, stance: stance)
            .sink { completion in
                
            } receiveValue: { [weak self] trickList in
                let sortedTrickList: [[Trick]] = TrickListManager.shared.sortTrickListByDifficulty(unsortedTrickList: trickList)
                switch stance {
                    
                case Stance.Stances.regular.rawValue:
                    print("HERE")
                    self?.regularTrickList = sortedTrickList
                    
                    for trickList in sortedTrickList {
                        print(trickList)
                        print("------------------")
                    }
                    
                case Stance.Stances.fakie.rawValue:
                    self?.fakieTrickList = sortedTrickList
                    
                case Stance.Stances._switch.rawValue:
                    self?.switchTrickList = sortedTrickList
                    
                case Stance.Stances.nollie.rawValue:
                    self?.nollieTrickList = sortedTrickList
                    
                default:
                    print("NO STANCE FOUND")
                }
            }
            .store(in: &cancellables)
    }
    
    func addListenerForTrickListInfo(userId: String) {
        TrickListInfoManager.shared.addListenerForTrickListInfo(userId: userId)
            .sink { completion in
                
            } receiveValue: { [weak self] trickListInfo in
                if !trickListInfo.isEmpty { self?.trickListInfo = trickListInfo[0] }
            }
            .store(in: &cancellables)
    }
    
    func fetchTrickListInfo(userId: String) {
        Task {
            self.trickListInfo = try await TrickListInfoManager.shared.fetchTrickListInfo(userId: userId)
        }
    }
    
    func fetchTrickList(userId: String, stance: String) {
        Task {
            let trickList = try await TrickListManager.shared.fetchTricksByStance(userId: userId, stance: stance)
            
            let sortedTrickList = TrickListManager.shared.sortTrickListByDifficulty(unsortedTrickList: trickList)
            
            switch stance {
            case Stance.Stances.regular.rawValue:
                self.regularTrickList = sortedTrickList
            case Stance.Stances.fakie.rawValue:
                self.fakieTrickList = sortedTrickList
            case Stance.Stances._switch.rawValue:
                self.switchTrickList = sortedTrickList
            case Stance.Stances.nollie.rawValue:
                self.nollieTrickList = sortedTrickList
            default:
                print("NO STANCE FOUND")
            }
        }
    }
}
