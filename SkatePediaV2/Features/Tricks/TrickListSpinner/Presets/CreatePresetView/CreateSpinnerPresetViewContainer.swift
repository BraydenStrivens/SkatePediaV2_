//
//  CreateSpinnerPresetViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/9/26.
//

import SwiftUI

struct CreateSpinnerPresetViewContainer: View {    
    @StateObject var viewModel: CreateSpinnerViewModel
    
    let initialPreset: SpinnerPreset?
    let presetCount: Int
    
    init(
        allTricks: [Trick],
        initialPreset: SpinnerPreset? = nil,
        presetCount: Int
    ) {
        self.initialPreset = initialPreset
        self.presetCount = presetCount
        
        _viewModel = StateObject(
            wrappedValue: CreateSpinnerViewModel(tricks: allTricks)
        )
    }
    
    var body: some View {
        CreateSpinnerPresetView(
            initialPreset: initialPreset,
            presetCount: presetCount,
            viewModel: viewModel
        )
    }
}
