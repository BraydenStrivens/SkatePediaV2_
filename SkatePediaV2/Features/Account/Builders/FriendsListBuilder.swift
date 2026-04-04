//
//  FriendsListBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/26.
//

import Foundation

struct FriendsListBuilder {
    static func build(userId: String, errorStore: ErrorStore) -> FriendsListView {
        let viewModel = FriendsListViewModel(errorStore: errorStore)
        return FriendsListView(userId: userId, viewModel: viewModel)
    }
}
