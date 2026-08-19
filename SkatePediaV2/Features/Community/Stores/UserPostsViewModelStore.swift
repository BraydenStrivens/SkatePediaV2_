//
//  UserPostsViewModelStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/10/26.
//

import Foundation

@MainActor
final class UserPostsViewModelStore: ObservableObject {

    private var cache: [String: UserPostPreviewViewModel] = [:]
    
    private let errorStore: ErrorStore
    
    init(errorStore: ErrorStore) {
        self.errorStore = errorStore
    }

    func viewModel(for user: User) -> UserPostPreviewViewModel {

        if let existing = cache[user.id] {
            return existing
        }

        let vm = UserPostPreviewViewModel(
            user: user,
            errorStore: errorStore
        )
        
        cache[user.id] = vm

        return vm
    }
}
