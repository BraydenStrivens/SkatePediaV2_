//
//  AccountRootView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/26.
//

import SwiftUI

/// Root view for the user's account flow.
///
/// Handles navigation within the account section and initializes
/// required view models and dependencies for child views.
///
/// - Parameters:
///   - user: The current user whose account is being displayed.
///   - errorStore: Used to present errors across account-related views.
struct AccountRootView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    
    @StateObject private var router: AccountRouter = AccountRouter()
    @StateObject private var userPostsVM: UserPostPreviewViewModel
    
    private let user: User
    private let errorStore: ErrorStore
    
    init(
        user: User,
        errorStore: ErrorStore
    ) {
        self.user = user
        self.errorStore = errorStore
        
        _userPostsVM = StateObject(
            wrappedValue: UserPostPreviewViewModel(
                user: user,
                errorStore: errorStore
            )
        )
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            CurrentUserAccountView(postsVM: userPostsVM, user: user)
                .navigationDestination(for: AccountRoute.self) { route in
                    switch route {
                    case .userAccount(let currentUser, let otherUser):
                        UserAccountBuilder.build(
                            currentUser: currentUser,
                            otherUser: otherUser,
                            appEnv: appEnv,
                            errorStore: errorStore
                        )
                    case .relationships:
                        RelationshipsBuilder.build(
                            user: user,
                            appEnv: appEnv,
                            errorStore: errorStore
                        )
                    case .blockedUsers(let currentUser):
                        BlockedUsersBuilder.build(
                            user: currentUser,
                            appEnv: appEnv,
                            errorStore: errorStore
                        )
                        
                    case .userPosts:
                        UserPostsView(viewModel: userPostsVM)
                        
                    case .userTricks(let stance):
                        TrickListPreviewView(user: user, stance: stance)
                        
                    case .accountOptions:
                        AccountOptionsBuilder.build(
                            user: user,
                            errorStore: errorStore
                        )
                        
                    case .profileSettings:
                        ProfileSettingsView(user: user)
                        
                    case .trickItemSettings:
                        TrickItemSettingsView(user: user)
                        
                    case .aboutSkatePedia:
                        AboutView()
                        
                    case .termsOfService:
                        TermsOfServiceView()
                        
                    case .privacyPolicy:
                        PrivacyPolicyView()
                    }
                }
        }
        .environmentObject(router)
    }
}
