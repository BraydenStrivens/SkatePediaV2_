//
//  CommunityBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/15/26.
//

import Foundation

@MainActor
struct CommunityBuilder {
    static func build(postStore: PostStore, errorStore: ErrorStore) -> CommunityView {
        let viewModel = CommunityViewModel(postStore: postStore, errorStore: errorStore)
        return CommunityView(viewModel: viewModel)
    }
}
