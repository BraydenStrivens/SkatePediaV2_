//
//  AccountSearchBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/16/26.
//

import Foundation

struct AccountSearchBuilder {
    
    static func build(currentUser: User, errorStore: ErrorStore) -> AccountSearchView {
        let viewModel = AccountSearchViewModel(errorStore: errorStore)
        return AccountSearchView(currentUser: currentUser, viewModel: viewModel)
    }
}
