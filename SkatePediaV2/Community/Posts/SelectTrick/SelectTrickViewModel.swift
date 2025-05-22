//
//  SelectTrickViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation
import FirebaseAuth

final class SelectTrickViewModel: ObservableObject {
    
    @Published var regularTricks: [Trick] = []
    @Published var fakieTricks: [Trick] = []
    @Published var switchTricks: [Trick] = []
    @Published var nollieTricks: [Trick] = []
    
    @Published var currentUserId: String? = nil
    
    init() {
        self.currentUserId = Auth.auth().currentUser?.uid
        
        Task {
            try await fetchTrickLists()
        }
    }

    @MainActor
    private func fetchTrickLists() async throws {
        if let userId = currentUserId {
            self.regularTricks = try await TrickListManager.shared.fetchTricksByStance(userId: userId, stance: "Regular")
            self.fakieTricks = try await TrickListManager.shared.fetchTricksByStance(userId: userId, stance: "Fakie")
            self.switchTricks = try await TrickListManager.shared.fetchTricksByStance(userId: userId, stance: "Switch")
            self.nollieTricks = try await TrickListManager.shared.fetchTricksByStance(userId: userId, stance: "Nollie")

        }
    }
}
