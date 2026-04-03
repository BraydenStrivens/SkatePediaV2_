//
//  TabbarView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/12/25.
//

import SwiftUI



struct TabbarView: View {
    @EnvironmentObject var userStore: UserStore
    
    @Environment(\.colorScheme) private var colorScheme

    @State private var tabbarHeight: CGFloat = 0
    @State private var currentTab: Int = 0
    
    var body: some View {
        if userStore.isLoading {
            ProgressView("Loading User...")
            
        } else if let user = userStore.user {
            tabbar(user.userId)
            
        } else if let error = userStore.blockingError {
            ContentUnavailableView {
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
    
    func tabbar(_ userId: String) -> some View {
        TabView(selection: $currentTab) {
            NavigationStack {
                TrickListViewContainer()
            }
            .tabbarAware()
            .tag(0)
            
            NavigationStack {
                ProsView()
                    .customNavHeader(
                        title: "Pro Skaters",
                        showDivider: true
                    )
            }
            .tabbarAware()
            .tag(1)
            
            NavigationStack {
                CommunityViewContainer()
            }
            .tabbarAware()
            .tag(2)
            
            NavigationStack {
                CurrentUserAccountView()
                    .customNavHeader(
                        title: "My Account",
                        showDivider: true
                    )
            }
            .tabbarAware()
            .tag(3)
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
    
    var customTabbarItems: some View {
        HStack(spacing: 0) {
            TabBarItem(
                defaultIcon: "skateboard",
                selectedIcon: "skateboard.fill",
                index: 0,
                label: "Tricks",
                currentTab: $currentTab
            )
            
            TabBarItem(
                defaultIcon: "figure.skateboarding",
                selectedIcon: "figure.skateboarding",
                index: 1,
                label: "Pros",
                currentTab: $currentTab
            )
            
            TabBarItem(
                defaultIcon: "person.3",
                selectedIcon: "person.3.fill",
                index: 2,
                label: "Community",
                currentTab: $currentTab
            )
            
            TabBarItem(
                defaultIcon: "person.circle",
                selectedIcon: "person.circle.fill",
                index: 3,
                label: "Profile",
                currentTab: $currentTab
            )
        }
    }
}

struct TabBarItem: View {
    let defaultIcon: String
    let selectedIcon: String
    let index: Int
    let label: String
    @Binding var currentTab: Int
    
    var isSelected: Bool {
        index == currentTab
    }
    
    var body: some View {
        Button {
            currentTab = index

        } label: {
            VStack {
                Image(systemName: isSelected ? selectedIcon : defaultIcon)
                    .foregroundColor(isSelected ? Color.tabbarItem : .primary)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(isSelected ? Color.tabbarItem : .primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.tabbarItem : .clear)
                .frame(height: 2)
                .padding(.horizontal, 8)
        }
    }
}
