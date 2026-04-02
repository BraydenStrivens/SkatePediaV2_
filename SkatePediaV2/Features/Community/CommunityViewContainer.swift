//
//  CommunityViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import SwiftUI

struct CommunityViewContainer: View {
    @EnvironmentObject var session: SessionContainer
    @EnvironmentObject var errorStore: ErrorStore
    
    
    var body: some View {
        let viewModel = CommunityViewModel(
            useCases: session.post,
            postStore: session.postStore,
            errorStore: errorStore
        )
        
        CommunityView(
            viewModel: viewModel
        )
    }
}
