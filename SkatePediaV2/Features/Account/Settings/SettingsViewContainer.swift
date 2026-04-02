//
//  SettingsViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/10/26.
//

import SwiftUI

struct SettingsViewContainer: View {
    @StateObject var viewModel: SettingsViewModel
    
    let user: User
    
    init(
        user: User,
        errorStore: ErrorStore,
        session: SessionContainer
    ) {
        self.user = user
        _viewModel = StateObject(
            wrappedValue: SettingsViewModel(
                user: user,
                errorStore: errorStore,
                useCases: session.user
            )
        )
    }
    
    var body: some View {
        SettingsView(user: user, viewModel: viewModel)
    }
}
