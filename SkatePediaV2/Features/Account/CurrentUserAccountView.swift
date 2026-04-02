//
//  CurrentUserAccountView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/12/26.
//

import SwiftUI

struct CurrentUserAccountView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var errorStore: ErrorStore
    @EnvironmentObject var session: SessionContainer
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentTab: AccountViewTab = .Tricks
    
    var body: some View {
        Group {
            if let user = userStore.user {
                content(user)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            NavigationLink(
                                destination: FriendsListViewContainer(
                                    userId: user.userId,
                                    errorStore: errorStore,
                                    session: session
                                )
                            ) {
                                Image(systemName: "person.2.circle")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(
                                destination: SettingsViewContainer(
                                    user: user,
                                    errorStore: errorStore,
                                    session: session
                                )
                            ) {
                                Image(systemName: "line.3.horizontal")
                            }
                        }
                    }
                
            } else {
                ContentUnavailableView {
                    Text("Error Fetching User")
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    func content(_ user: User) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                profileDetailsView(user)
                
                tabSelector
                
                Group {
                    switch currentTab {
                    case .Tricks:
                        UserTrickListView(user: user)
                        
                    case .Posts:
                        UserPostPreviewViewContainer(
                            user: user,
                            errorStore: errorStore,
                            session: session
                        )
                    }
                }
                .padding(14)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).inset)
            }
            .padding(14)
        }
        .frame(maxHeight: .infinity)
    }
    
    func profileDetailsView(_ user: User) -> some View {
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
