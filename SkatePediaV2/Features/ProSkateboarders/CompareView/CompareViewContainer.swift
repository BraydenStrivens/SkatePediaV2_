//
//  CompareViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/27/26.
//

import SwiftUI

struct CompareViewContainer: View {
    
    @StateObject var viewModel: CompareViewModel
    
    let trickData: TrickData
    let trickItem: TrickItem?
    let proVideo: ProSkaterVideo?
    
    init(
        trickData: TrickData,
        trickItem: TrickItem? = nil,
        proVideo: ProSkaterVideo? = nil,
        errorStore: ErrorStore,
        session: SessionContainer
    ) {
        self.trickData = trickData
        self.trickItem = trickItem
        self.proVideo = proVideo
        
        _viewModel = StateObject(
            wrappedValue: CompareViewModel(
                errorStore: errorStore,
                useCases: session.trickItem,
                trickItem: trickItem,
                proVideo: proVideo
            )
        )
    }
    var body: some View {
        CompareView(
            trickData: trickData,
            trickItem: trickItem,
            proVideo: proVideo,
            viewModel: viewModel
        )
        .customNavHeader(
            title: "Compare With Pro",
            showDivider: true
        )
    }
}
