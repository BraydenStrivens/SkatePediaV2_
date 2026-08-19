//
//  BlockedUsersView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/23/26.
//

import SwiftUI

struct BlockedUsersView: View {
    
    @StateObject var viewModel: BlockedUsersViewModel
    let user: User
    
    var body: some View {
        Group {
            switch viewModel.requestState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if viewModel.blockedUsers.isEmpty {
                    SPContentUnavailableView(
                        title: "No Blocked Users",
                        type: .emptyList
                    )
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.blockedUsers) { userBlock in
                                BlockedUserCell(
                                    blockedUsersVM: viewModel,
                                    currentUser: user,
                                    userBlock: userBlock
                                )
                                .task {
                                    if userBlock == viewModel.blockedUsers.last {
                                        Task {
                                            await viewModel.fetchMore(userId: user.userId)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            case .failure(let sPError):
                SPContentUnavailableView(
                    title: "Error Fetching Blocked Users",
                    description: sPError.errorDescription,
                    type: .blockingError
                )
            }
        }
        .customNavHeader(title: "Blocked Users")
        .task {
            await viewModel.initialFetch(userId: user.userId)
        }
    }
}
