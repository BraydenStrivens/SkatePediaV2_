//
//  RootView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

/// Determines which view to display as the app's root based on authentication state.
///
/// - If the auth state is loading, displays a centered `CustomProgressView`.
/// - If the user is authenticated, displays the `TabbarView` and starts listening to user data.
/// - If the user is not authenticated, displays the authentication flow via `AuthRootView`.
///
/// Additionally, stops listening to user data and clears relevant stores when the user logs out.
struct RootView: View {
    @EnvironmentObject private var authStore: AuthenticationStore
    @EnvironmentObject private var appEnv: AppEnvironment
        
    var body: some View {
        Group {
            if authStore.isLoading {
                CustomProgressView(placement: .center)
                
            } else if let session = authStore.userSession {
                TabbarView()
                    .ignoresSafeArea(.keyboard)
                    .task(id: session.uid) {
                        appEnv.userStore.startListening(uid: session.uid)
                    }
                
            } else {
                AuthRootView()
            }
        }
        .onChange(of: authStore.userSession) { _, newSession in
            if newSession == nil {
                appEnv.resetUserSpecificGlobalState()
            }
        }
    }
}
