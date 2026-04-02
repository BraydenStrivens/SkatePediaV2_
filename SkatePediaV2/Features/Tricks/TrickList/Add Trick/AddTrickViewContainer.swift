//
//  AddTrickViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import SwiftUI

struct AddTrickViewContainer: View {
    @EnvironmentObject var session: SessionContainer
    @EnvironmentObject var errorStore: ErrorStore
    
    let userId: String
    let stance: TrickStance
    let trickList: [Trick]
    
    var body: some View {
        let viewModel = AddTrickViewModel(
            useCases: session.trickList,
            errorStore: errorStore
        )
        
        AddTrickView(
            userId: userId,
            stance: stance,
            trickList: trickList,
            viewModel: viewModel
        )
    }
}
