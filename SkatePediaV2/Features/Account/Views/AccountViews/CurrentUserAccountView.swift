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
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var currentTab: AccountViewTab = .Tricks
    
    @ObservedObject var postsVM: UserPostPreviewViewModel
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                profileDetailsView
                
                tabSelector
                
                Group {
                    switch currentTab {
                    case .Tricks:
                        UserTrickListProgressView(user: user)
                        
                    case .Posts:
                        UserPostPreviewsView(user: user, viewModel: postsVM)
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
                    router.push(.friendsList)
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
        HStack(alignment: .top, spacing: 12) {
            CircularProfileImageView(
                photoUrl: user.profilePhoto?.photoUrl,
                size: .xLarge
            )
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 12) {
                    Text(user.username)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(user.stance.camalCase)
                        .fontWeight(.semibold)
                        .font(.footnote)
                }
                
                if !user.bio.isEmpty {
                    CollapsibleTextView(text: user.bio, lineLimit: 4, font: .body)
                } else {
                    Text("")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(minHeight: 100, alignment: .top)
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).inset)
    }
    
    /// Tab selector for switching between tricks and posts.
    var tabSelector: some View {
        HStack(spacing: 20) {
            Spacer()
            
            ForEach(AccountViewTab.allCases) { tab in
                let isCurrentTab = currentTab == tab
                
                VStack {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(isCurrentTab ? .semibold : .regular)
                        .frame(height: 40)
                        .frame(maxWidth: 150)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark
                                      ? Color(.systemGray6).opacity(isCurrentTab ? 1 : 0.0)
                                      : Color(.systemBackground)
                                )
                                .stroke(
                                    LinearGradient(colors: [
                                        isCurrentTab ? .primary.opacity(0.2) : .clear,
                                        isCurrentTab ? .black : .clear,
                                    ],
                                                   startPoint: .top,
                                                   endPoint: .bottom
                                                  )
                                )
                                .shadow(color: isCurrentTab
                                        ? colorScheme == .dark ? .clear : .black.opacity(0.25)
                                        : .clear,
                                        radius: 3,
                                        y: 2
                                )
                        }
                }
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
