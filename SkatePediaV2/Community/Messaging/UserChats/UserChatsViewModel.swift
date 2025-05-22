//
//  MessagesViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class UserChatsViewModel: ObservableObject {
    @Published var chattingWithUsers: [User] = []
    @Published var searchString: String = ""
    @Published var isFetching: Bool = false
    
    init() {
        Task {
            try await fetchMessages()
        }
    }
    @MainActor
    func fetchMessages() async throws {
        self.isFetching = true
        let users = try await MessagingManager.shared.getAllUserChats()
        self.chattingWithUsers.append(contentsOf: users)

        self.isFetching = false
    }
    
    func matchesFilter(user: User?) -> Bool {
        guard let user = user else { return false }
        
        var matched = true
        
        for index in 0 ..< searchString.count {
            let searchChar = String(describing: searchString[index])
            let usernameChar = String(describing: user.username[index])
            
            if searchChar.caseInsensitiveCompare(usernameChar) != .orderedSame {
                matched = false
                break
            }
        }
        
        return matched
    }
}
