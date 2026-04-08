//
//  AddTrickItemViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import SwiftUI

struct AddTrickItemViewContainer: View {
    @EnvironmentObject var session: SessionContainer
    
    let userId: String
    let trick: Trick
    
    var body: some View {
        let viewModel = AddTrickItemViewModel(
            useCases: session.trickItem
        )
        
        AddTrickItemView(
            userId: userId,
            trick: trick,
            viewModel: viewModel
        )
    }
}
