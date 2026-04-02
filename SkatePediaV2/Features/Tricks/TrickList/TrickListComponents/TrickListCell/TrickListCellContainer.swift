//
//  TrickListCellContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import SwiftUI

struct TrickListCellContainer: View {
    @EnvironmentObject var session: SessionContainer
    @EnvironmentObject var errorStore: ErrorStore
    
    let userId: String
    let trick: Trick
    
    var body: some View {
        let viewModel = TrickListCellViewModel(
            useCases: session.trickList,
            errorStore: errorStore
        )
        
        TrickListCell(
            userId: userId,
            trick: trick,
            viewModel: viewModel
        )
    }
}
