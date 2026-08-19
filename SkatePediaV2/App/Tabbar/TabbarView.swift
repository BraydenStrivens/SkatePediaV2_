//
//  TabbarView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/12/25.
//

import SwiftUI

/// Displays the main tab bar interface of the app.
///
/// - Handles four tabs:
///   1. Tricks (`TrickListRootView`)
///   2. Pro Skaters (`ProsRootView`)
///   3. Community (`CommunityRootView`)
///   4. User Profile (`AccountRootView`)
///
/// - Shows a loading view while the user data is loading.
/// - Shows a blocking error view with logout option if user data fails to load.
/// - Uses `tabbarAware()` to apply bottom padding for the custom tab bar height.
/// - Each tab's navigation is controlled with custom `Route` enums with `NavigationDestination`.
struct TabbarView: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var appEnv: AppEnvironment
    @EnvironmentObject private var errorStore: ErrorStore
    @EnvironmentObject private var trickListStore: TrickListStore
    @EnvironmentObject private var tabRouter: TabRouter

    // MARK: State
    @State private var tabbarHeight: CGFloat = 0
    
    // MARK: Body
    var body: some View {
        if userStore.isLoading {
            ProgressView("Loading User...")
            
        } else if let user = userStore.user {
            tabbar(user, errorStore)
            
        } else if let error = userStore.blockingError {
            ContentUnavailableView {
                // User listener timed out
                VStack {
                    Text("Failed to Load User")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(error.errorDescription ?? "Something went wrong...")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    
                    Button {
                        try? AuthenticationService.shared.signOut()
                    } label: {
                        Text("Logout")
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).coloredProtruded(color: Color.button))
                    }
                }
            }
            
        } else {
            ProgressView("Loading User...")
        }
    }
    
    // MARK: Subviews
    
    /// Returns a TabView with all main app tabs and applies bottom padding for the custom tab bar.
    ///
    /// - Parameters:
    ///  - user: The authenticated user's model
    ///  - errorStore: Global store used for storing and presenting errors.
    ///
    /// - Returns: A SwiftUI view containing the tab bar interface.
    private func tabbar(
        _ user: User,
        _ errorStore: ErrorStore
    ) -> some View {
        
        TabView(selection: $tabRouter.selectedTab) {
            TrickListRootView(user: user, appEnv: appEnv)
                .tabbarAware()
                .ignoresSafeArea(.keyboard)
                .tag(Tab.tricks)
            
            ProsRootView()
                .tabbarAware()
                .ignoresSafeArea(.keyboard)
                .tag(Tab.pros)
            
            CommunityRootView(errorStore: errorStore)
                .tabbarAware()
                .ignoresSafeArea(.keyboard)
                .tag(Tab.community)
            
            AccountRootView(
                user: user,
                errorStore: errorStore
            )
            .tabbarAware()
            .ignoresSafeArea(.keyboard)
            .tag(Tab.profile)
        }
        .environment(\.tabbarHeight, tabbarHeight)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            customTabbarItems
                .padding(.horizontal)
                .background(.ultraThinMaterial)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                tabbarHeight = proxy.size.height
                            }
                    }
                }
        }
    }
    
    /// The custom tab bar items displayed at the bottom of the screen.
    private var customTabbarItems: some View {
        HStack(spacing: 0) {
            TabBarItem(
                defaultIcon: "skateboard",
                selectedIcon: "skateboard.fill",
                tab: .tricks,
                label: "Tricks",
                currentTab: $tabRouter.selectedTab
            )
            
            TabBarItem(
                defaultIcon: "figure.skateboarding",
                selectedIcon: "figure.skateboarding",
                tab: .pros,
                label: "Pros",
                currentTab: $tabRouter.selectedTab
            )
            
            TabBarItem(
                defaultIcon: "person.3",
                selectedIcon: "person.3.fill",
                tab: .community,
                label: "Community",
                currentTab: $tabRouter.selectedTab
            )
            
            TabBarItem(
                defaultIcon: "person.circle",
                selectedIcon: "person.circle.fill",
                tab: .profile,
                label: "Profile",
                currentTab: $tabRouter.selectedTab
            )
        }
    }
}
