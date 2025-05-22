//
//  NewMessageViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/25.
//

import Foundation

final class NewMessageViewModel: ObservableObject {
    @Published var foundUsers: [User] = []
    @Published var search: String = ""
    @Published var isSearching: Bool = false
    
    @MainActor
    func searchUsers() async throws {
        self.isSearching = true
        self.foundUsers = try await UserManager.shared.fetchUserByUsername(searchString: search, includeCurrentUser: false)
        self.isSearching = false
    }
    
    @MainActor
    func clearFoundUsers() {
        self.foundUsers = []
    }
}
