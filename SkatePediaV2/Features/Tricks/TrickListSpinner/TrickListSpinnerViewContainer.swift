//
//  TrickListSpinnerViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import SwiftUI

struct TrickListSpinnerViewContainer: View {
    @StateObject var viewModel: TrickListSpinnerViewModel
    
    init(trickListStore: TrickListStore) {
        _viewModel = StateObject(
            wrappedValue: TrickListSpinnerViewModel(
                trickListStore: trickListStore
            )
        )
    }
    var body: some View {
        TrickListSpinnerView(viewModel: viewModel)
    }
}
