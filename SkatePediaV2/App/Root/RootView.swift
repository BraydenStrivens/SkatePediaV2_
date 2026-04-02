//
//  RootView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

/// Defines the layout of items in the 'MainMenuView'.
struct RootView: View {
    @EnvironmentObject var authStore: AuthenticationStore
    @EnvironmentObject var errorStore: ErrorStore
    @EnvironmentObject var sessionContainer: SessionContainer
    
    var body: some View {
        Group {
            if authStore.isLoading {
                CustomProgressView(placement: .center)
                
            } else if let session = authStore.userSession {
                TabbarView()
                    .ignoresSafeArea(.keyboard)
                    .task(id: session.uid) {
                        sessionContainer.userStore.startListening(uid: session.uid)
                    }
                
            } else {
                NavigationStack {
                    LoginViewBuilder(
                        errorStore: errorStore
                    )
                }
            }
        }
        .onChange(of: authStore.userSession) { _, newSession in
            if newSession == nil {
                sessionContainer.userStore.stopListening()
                sessionContainer.trickListStore.clear()
                sessionContainer.postStore.clear()
            }
        }
    }
}
