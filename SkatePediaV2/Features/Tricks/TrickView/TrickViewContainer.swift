//
//  TrickViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import SwiftUI

struct TrickViewContainer: View {
    @EnvironmentObject var session: SessionContainer
    
    let userId: String
    let trick: Trick
    
    var body: some View {
        let viewModel = TrickViewModel(
            useCases: session.trickItem
        )
        
        TrickView(
            userId: userId,
            trick: trick,
            viewModel: viewModel
        )
    }
}
