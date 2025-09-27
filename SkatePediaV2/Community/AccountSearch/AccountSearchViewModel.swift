//
//  AccountSearchViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation

///
/// Class containing functions for quering users in the database based off of their username.
///
final class AccountSearchViewModel: ObservableObject {
    
    @Published var search: String = ""
    @Published var foundUsers: [User] = []
    
    ///
    /// Queries the database for users whose username matches a string inputted by the current user.
    ///
    @MainActor
    func searchUsers() async throws {
        self.foundUsers = try await UserManager.shared.fetchUserByUsername(searchString: search, includeCurrentUser: true)
    }
    
    ///
    /// Clears the array of matched users. 
    ///
    @MainActor
    func clearFoundUsers() {
        self.foundUsers = []
    }
}
