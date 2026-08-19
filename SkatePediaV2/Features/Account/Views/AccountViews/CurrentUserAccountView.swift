//
//  CurrentUserAccountView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/12/26.
//

import SwiftUI

/// View representing the current user's account screen.
///
/// Displays profile information and allows switching between
/// user-created tricks and posts. Handles navigation to related
/// account routes via `AccountRouter`.
///
/// - Parameters:
///   - postsVM: View model managing the user's post previews.
///   - user: The current user being displayed.
struct CurrentUserAccountView: View {
    @EnvironmentObject private var router: AccountRouter
    @EnvironmentObject private var trickListStore: TrickListStore
    @EnvironmentObject private var userStore: UserStore
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var currentTab: AccountViewTab = .Tricks
    
    @ObservedObject var postsVM: UserPostPreviewViewModel
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                profileDetailsView
                
                favoriteTricks
                
                tabSelector
                
                Group {
                    switch currentTab {
                    case .Tricks:
                        UserTrickListProgressView(
                            user: user,
                            onNavigate: { stance in
                                router.push(.userTricks(stance: stance))
                            }
                        )
                        
                    case .Posts:
                        UserPostPreviewsView(
                            user: user,
                            onNavigate: {
                                router.push(.userPosts)
                            },
                            viewModel: postsVM)
                    }
                }
                .padding(14)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).inset)
            }
            .padding(14)
        }
        .scrollIndicators(.hidden)
        .frame(maxHeight: .infinity)
        .customNavHeader(
            title: "My Account",
            showDivider: true
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.push(.relationships)
                } label: {
                    Image(systemName: "person.2.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.push(.accountOptions)
                } label: {
                    Image(systemName: "line.3.horizontal")
                }
            }
        }
    }
    
    /// Displays the user's profile information.
    ///
    /// Includes profile image, username, stance, and bio.
    var profileDetailsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                CircularProfileImageView(
                    photoUrl: user.profilePhoto?.photoUrl,
                    size: .xLarge
                )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(user.stance.camalCase)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if !user.bio.isEmpty {
                CollapsibleTextView(text: user.bio, lineLimit: 4, font: .body)
            } else {
                Text("")
            }
        }
    }
    
    private func favoriteTricksDisplayString(
        ids favoriteTrickIds: [String]
    ) -> String {
        let names: [String] = favoriteTrickIds.compactMap { trickId in
            guard let trick = trickListStore.trick(trickId) else {
                return nil
            }
            
            return userStore.getTrickName(trick)
        }
        
        return names.joined(separator: " ,  ")
    }
    
    var favoriteTricks: some View {
        Group {
            if let favoriteTrickIds = user.favoriteTricks {
        
                FlowLayout(alignment: .center, spacing: 8) {
                    
                    ForEach(favoriteTrickIds, id: \.self) { trickId in
                        if let trick = trickListStore.trick(trickId) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                
                                Text(userStore.getTrickName(trick))
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Capsule())
                        }
                    }
                }
                
            } else {
                EmptyView()
            }
        }
    }
    
    /// Tab selector for switching between tricks and posts.
    var tabSelector: some View {
        HStack(spacing: 20) {
            Spacer()
            
            ForEach(AccountViewTab.allCases) { tab in
                let isCurrentTab = currentTab == tab
                
                HStack(spacing: 4) {
                    Image(systemName: tab == .Tricks
                          ? isCurrentTab ? "skateboard.fill" : "skateboard"
                          : isCurrentTab ? "list.bullet.rectangle.portrait.fill" : "list.bullet.rectangle.portrait"
                    )
                    
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(isCurrentTab ? .semibold : .regular)
                }
                .frame(maxWidth: 150)
                .padding(.vertical)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(isCurrentTab ? .primary : Color.clear)
                        .frame(height: 2)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.currentTab = tab
                    }
                }
            }
            Spacer()
        }
    }
}
