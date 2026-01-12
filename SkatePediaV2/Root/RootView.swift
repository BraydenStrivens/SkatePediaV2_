//
//  RootView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

/// Defines the layout of items in the 'MainMenuView'.
struct RootView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        Group {
            if authViewModel.isLoading {
                ProgressView()
                
            } else if authViewModel.userSession != nil {
                TabbarView()
            } else {
                NavigationView {
                    LoginView()
                }
                .tint(Color("AccentColor"))
            }
        }
    }
}
