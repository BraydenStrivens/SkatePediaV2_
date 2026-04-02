//
//  TrickItemViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import SwiftUI

struct TrickItemViewContainer: View {
    @EnvironmentObject var session: SessionContainer
    @EnvironmentObject var errorStore: ErrorStore
    
    let userId: String
    let trickItem: TrickItem
    let trick: Trick
    
    var body: some View {
        let viewModel = TrickItemViewModel(
            trickItemUseCases: session.trickItem,
            postUseCases: session.post,
            errorStore: errorStore,
            trickItem: trickItem
        )
        
        TrickItemView(
            userId: userId,
            trickItem: trickItem,
            trick: trick,
            viewModel: viewModel
        )
    }
}
