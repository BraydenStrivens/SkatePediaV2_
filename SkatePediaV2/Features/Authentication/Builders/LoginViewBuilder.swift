//
//  LoginViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import SwiftUI

struct LoginViewBuilder: View {
    @StateObject var viewModel: LoginViewModel
    
    init(errorStore: ErrorStore) {
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(
                errorStore: errorStore
            )
        )
    }
    
    var body: some View {
        LoginView(viewModel: viewModel)
    }
}

