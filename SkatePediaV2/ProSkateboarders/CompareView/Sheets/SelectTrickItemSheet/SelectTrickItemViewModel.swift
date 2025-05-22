//
//  SelectTrickItemSheetModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/25.
//

import Foundation
import FirebaseAuth

final class SelectTrickItemViewModel: ObservableObject {
    @Published var trickItems: [TrickItem] = []
    @Published var currentUser: User? = nil
    @Published var loading: Bool = false
    @Published var fetched: Bool = false
    
    @MainActor
    func fetchTrickItemsForTrick(trickId: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.loading = true
        
        self.currentUser = try await UserManager.shared.fetchUser(withUid: currentUid)
        let availableTrickItems = try await TrickItemManager.shared.getTrickItems(userId: currentUid, trickId: trickId)
        self.trickItems.append(contentsOf: availableTrickItems)
            
        self.loading = false
        self.fetched = true
    }
}
