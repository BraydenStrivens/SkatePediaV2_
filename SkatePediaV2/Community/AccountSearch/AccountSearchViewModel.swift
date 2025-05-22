//
//  AccountSearchViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation

final class AccountSearchViewModel: ObservableObject {
    
    @Published var search: String = ""
    @Published var foundUsers: [User] = []
    
    @MainActor
    func searchUsers() async throws {
        self.foundUsers = try await UserManager.shared.fetchUserByUsername(searchString: search, includeCurrentUser: true)
    }
    
    @MainActor
    func clearFoundUsers() {
        self.foundUsers = []
    }
}
