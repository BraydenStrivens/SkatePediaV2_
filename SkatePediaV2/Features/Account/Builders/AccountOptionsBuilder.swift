//
//  ProfileOptionsBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/26.
//

import Foundation

@MainActor
struct AccountOptionsBuilder {
    static func build(user: User, errorStore: ErrorStore) -> AccountOptionsView {
        let viewModel = AccountOptionsViewModel(user: user, errorStore: errorStore)
        return AccountOptionsView(user: user, viewModel: viewModel)
    }
}
