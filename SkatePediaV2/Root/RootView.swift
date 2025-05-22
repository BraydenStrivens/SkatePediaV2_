//
//  RootView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

/// Defines the layout of items in the 'MainMenuView'.
struct RootView: View {
    @StateObject var viewModel = RootViewModel()
    
    var body: some View {
        
        
        Group {
            if viewModel.userSession != nil {
//                let _ = AuthenticationManager.shared.signOut()

                TabbarView()
            } else {
                LoginView()
            }
        }
    }
}


//#Preview {
//    RootView()
//}
