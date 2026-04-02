//
//  RegisterViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import SwiftUI

struct RegisterViewBuilder: View {
    @StateObject var viewModel: RegisterViewModel
    
    init(errorStore: ErrorStore) {
        _viewModel = StateObject(
            wrappedValue: RegisterViewModel(
                errorStore: errorStore
            )
        )
    }
    var body: some View {
        RegisterView(viewModel: viewModel)
    }
}
