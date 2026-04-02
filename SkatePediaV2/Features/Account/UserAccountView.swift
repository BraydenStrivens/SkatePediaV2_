//
//  MyAccountView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

struct UserAccountView: View {
    @EnvironmentObject var overlayManager: OverlayManager
    @EnvironmentObject var errorStore: ErrorStore
    @EnvironmentObject var session: SessionContainer
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentTab: AccountViewTab = .Tricks
    
    @ObservedObject var viewModel: UserAccountViewModel
    let currentUser: User
    let otherUser: User
    
    init(
        currentUser: User,
        otherUser: User,
        viewModel: UserAccountViewModel
    ) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                profileDetailsView
                
                tabSelector
                
                Group {
                    switch currentTab {
                    case .Tricks:
                        if otherUser.settings.profileSettings.trickListDataIsPrivate {
                            ContentUnavailableView(
                                "Private Account",
                                systemImage: "exclamationmark.lock"
                            )
                        } else {
                            UserTrickListView(user: otherUser)
                        }
                        
                    case .Posts:
                        UserPostPreviewViewContainer(
                            user: otherUser,
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
        .toolbar {
            if otherUser.userId != currentUser.userId {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            let success = await viewModel.sendFriendRequest(currentUser, to: otherUser)
                            
                            if success {
                                _ = overlayManager.present(level: .popup) { id in
                                    ErrorPopup(
                                        error: AppError(
                                            title: "Operation Successful",
                                            message: "Friend request has been sent."
                                        ),
                                        style: .autoDismiss(seconds: 2),
                                        onDismiss: { overlayManager.dismiss(id: id) }
                                    )
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
//                ToolbarItem(placement: .topBarLeading) {
//                    NavigationLink(
//                        destination: ChatMessagesViewContainer(
//                            currentUser: currentUser,
//                            withUserData: UserData(user: otherUser),
//                            errorStore: errorStore
//                        )
//                    ) {
//                        Image(systemName: "bubble")
//                            .resizable()
//                            .frame(width: 20, height: 20)
//                    }
//                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.reportUser(currentUser, report: otherUser)
                        }
                    } label: {
                        Image(systemName: "exclamationmark.square")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
            }
        }
    }
    
    var profileDetailsView: some View {
        HStack(alignment: .top, spacing: 12) {
            CircularProfileImageView(
                photoUrl: otherUser.profilePhoto?.photoUrl,
                size: .xLarge
            )
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 12) {
                    Text(otherUser.username)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(otherUser.stance.camalCase)
                        .fontWeight(.semibold)
                        .font(.footnote)
                }
                
                if !otherUser.bio.isEmpty {
                    CollapsibleTextView(text: otherUser.bio, lineLimit: 4, font: .body)
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
