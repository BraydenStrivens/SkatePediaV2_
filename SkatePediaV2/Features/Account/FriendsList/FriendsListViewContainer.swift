//
//  FriendListViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/11/26.
//

import SwiftUI

struct FriendsListViewContainer: View {
    @StateObject var viewModel: FriendsListViewModel
    
    let userId: String
    
    init(
        userId: String,
        errorStore: ErrorStore,
        session: SessionContainer
    ) {
        self.userId = userId
        
        _viewModel = StateObject(
            wrappedValue: FriendsListViewModel(
                errorStore: errorStore,
                useCases: session.user
            )
        )
    }
    var body: some View {
        FriendsListView(
            userId: userId,
            viewModel: viewModel
        )
        .customNavHeader(
            title: "Friends"
        )
    }
}
