//
//  MyAccountView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

struct UserAccountView: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var router: CommunityRouter
    @EnvironmentObject private var overlayManager: OverlayManager
    @EnvironmentObject private var postVMStore: UserPostsViewModelStore
    @EnvironmentObject private var appEnv: AppEnvironment
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var trickListStore: TrickListStore
    @EnvironmentObject private var errorStore: ErrorStore
    
    @State private var currentTab: AccountViewTab = .Tricks
    @State private var showReportPopup: Bool = false
    
    @StateObject var viewModel: UserAccountViewModel
    @StateObject var userPostsVM: UserPostPreviewViewModel
    let currentUser: User
    let otherUser: User
    
    init(
        currentUser: User,
        otherUser: User,
        viewModel: UserAccountViewModel,
        userPostsVM: UserPostPreviewViewModel
    ) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        _viewModel = StateObject(wrappedValue: viewModel)
        _userPostsVM = StateObject(wrappedValue: userPostsVM)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                profileDetailsView
                
                favoriteTricks
                
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
                            UserTrickListProgressView(
                                user: otherUser,
                                onNavigate: { stance in
                                    router.push(.userTrickList(user: otherUser, stance: stance))
                                }
                            )
                        }
                        
                    case .Posts:
                        UserPostPreviewsView(
                            user: otherUser,
                            onNavigate: {
                                router.push(.userPosts(user: otherUser))
                            },
                            viewModel: postVMStore.viewModel(for: otherUser)
                        )
                    }
                }
                .padding(14)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).inset)
            }
            .padding(14)
        }
        .spSheet(
            isPresented: $showReportPopup,
            detent: .full,
            content: {
                ReportItemSheetBuilder.build(
                    currentUid: currentUser.userId,
                    otherUid: otherUser.userId,
                    reportType: .profile,
                    appEnv: appEnv,
                    errorStore: errorStore
                )
            }
        )
        .customNavHeader(
            title: "@\(otherUser.username)",
            showDivider: false
        )
        .toolbar {
            if otherUser.userId != currentUser.userId {
                toolbar
            }
        }
    }
    
    private func toggleReportPopup() {
        withAnimation(.smooth) {
            showReportPopup.toggle()
        }
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                Task {
                    let appSuccess = await viewModel.sendFriendRequest(currentUser, to: otherUser)
                    
                    if let appSuccess {
                        _ = overlayManager.present(level: .popup) { id in
                            SuccessPopup(
                                appSuccess: appSuccess,
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
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Report User") {
                    toggleReportPopup()
                }
                
                Button("Block User") {
                    Task {
                        let appSuccess = await viewModel.blockUser(
                            currentUid: currentUser.userId,
                            otherUid: otherUser.userId
                        )
                        
                        if let appSuccess {
                            _ = overlayManager.present(level: .popup) { id in
                                SuccessPopup(
                                    appSuccess: appSuccess,
                                    onDismiss: { overlayManager.dismiss(id: id) }
                                )
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "exclamationmark.square")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
    }
    
    var profileDetailsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                CircularProfileImageView(
                    photoUrl: otherUser.profilePhoto?.photoUrl,
                    size: .xLarge
                )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(otherUser.username)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(otherUser.stance.camalCase)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if !otherUser.bio.isEmpty {
                CollapsibleTextView(text: otherUser.bio, lineLimit: 4, font: .body)
            } else {
                Text("")
            }
        }
    }
    
    var favoriteTricks: some View {
        Group {
            if let favoriteTrickIds = otherUser.favoriteTricks {
        
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
