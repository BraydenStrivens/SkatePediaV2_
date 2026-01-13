//
//  TabbarView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/12/25.
//

import SwiftUI

struct TabbarView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        // Creates a tab bar to navigate between 'Tricks', 'Pros', 'Community', 'Profile', and 'Settings' views
        TabView {
            CustomNavView {
                TrickListView()
                    .customNavBarItems(title: "Trick List", subtitle: "", backButtonHidden: true)

            }
            .tabItem {
                Label("Tricks", systemImage: "skateboard")
            }
            
            CustomNavView {
                ProsView()
                    .customNavBarItems(title: "Pro Skaters", subtitle: "", backButtonHidden: true)

            }
            .tabItem {
                Label("Pros", systemImage: "figure.skateboarding")
            }
            
            CustomNavView {
                CommunityView()
                    .customNavBarItems(title: "", subtitle: "", backButtonHidden: true)
            }
            .tabItem {
                Label("Community", systemImage: "person.3.sequence.fill")
            }
            
            CustomNavView {
//                CurrentUserAccountView()
                UserAccountView()
                    .customNavBarItems(title: "Profile", subtitle: "", backButtonHidden: true)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
            CustomNavView {
                SettingsView()
                    .customNavBarItems(title: "Settings", subtitle: "", backButtonHidden: true)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .tint(Color("tabbarItemColor"))
    }
}
