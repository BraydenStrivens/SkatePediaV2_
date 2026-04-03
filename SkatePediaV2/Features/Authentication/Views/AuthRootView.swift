//
//  AuthRootView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import SwiftUI

/// Root container for the authentication flow.
///
/// `AuthRootView` is responsible for:
/// - Creating and owning the authentication navigation state (`AuthRouter`)
/// - Defining the navigation stack and route destinations
/// - Composing the initial screen (`LoginView`)
/// - Injecting shared dependencies (e.g. `ErrorStore`, `AuthRouter`) into child views
///
/// This view acts as the composition root for all authentication-related screens.
///
struct AuthRootView: View {
    @EnvironmentObject var errorStore: ErrorStore
    
    @StateObject private var router = AuthRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            
            LoginBuilder.build(errorStore: errorStore)
                .navigationDestination(for: AuthRoute.self) { route in
                    
                    switch route {
                    case .register:
                        RegisterBuilder.build(errorStore: errorStore)
                    }
                }
        }
        .environmentObject(router)
    }
}
