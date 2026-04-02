//
//  TrickListViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import SwiftUI

struct TrickListViewContainer: View {
    @EnvironmentObject var session: SessionContainer
    @EnvironmentObject var errorStore: ErrorStore
    
    var body: some View {
        let viewModel = TrickListViewModel(
            useCases: session.trickList,
            errorStore: errorStore
        )
        
        TrickListView(
            viewModel: viewModel
        )
        .customNavHeader(
            title: "Trick List",
            background: Color(.systemBackground)
        )
    }
}
