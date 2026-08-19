//
//  CommunityRootView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/15/26.
//

import SwiftUI

struct CommunityRootView: View {
    @EnvironmentObject private var appEnv: AppEnvironment
    @EnvironmentObject private var postStore: PostStore
    @EnvironmentObject private var trickItemStore: TrickItemStore
    @EnvironmentObject private var errorStore: ErrorStore
    @EnvironmentObject private var notificationStore: NotificationStore
    
    @StateObject private var router = CommunityRouter()
    @StateObject private var userPostsVMStore: UserPostsViewModelStore
    
    init(errorStore: ErrorStore) {
        _userPostsVMStore = StateObject(
            wrappedValue: UserPostsViewModelStore(errorStore: errorStore)
        )
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            CommunityBuilder.build(postStore: postStore, errorStore: errorStore)
                .navigationDestination(for: CommunityRoute.self) { route in
                    switch route {
                    case .accountSearch(let currentUser):
                        AccountSearchBuilder.build(
                            currentUser: currentUser,
                            errorStore: errorStore
                        )
                        
                    case .userAccount(let currentUser, let otherUser):
                        UserAccountBuilder.build(
                            currentUser: currentUser,
                            otherUser: otherUser,
                            appEnv: appEnv,
                            errorStore: errorStore
                        )
                        
                    case .userTrickList(let user, let stance):
                        TrickListPreviewView(
                            user: user,
                            stance: stance
                        )
                        
                    case .userPosts(let user):
                        UserPostsView(
                            viewModel: userPostsVMStore.viewModel(for: user)
                        )
                        
                    case .notifications(let currentUser):
                        NotificationBuilder.build(
                            user: currentUser,
                            errorStore: errorStore,
                            appEnv: appEnv
                        )

                    case .selectTrick(let user):
                        SelectTrickView(user: user)
                        
                    case .selectTrickItem(let user, let trick):
                        SelectTrickItemView(
                            user: user,
                            trick: trick
                        )
                        
                    case .addPost(let user, let trick, let trickItem):
                        AddPostBuilder.build(
                            user: user,
                            trick: trick,
                            trickItem: trickItem,
                            postStore: postStore,
                            errorStore: errorStore,
                            onSuccess: {
                                trickItemStore.updateTrickItemPosted(
                                    posted: true,
                                    trickId: trick.id,
                                    trickItemId: trickItem.id
                                )
                                router.reset()
                            }
                        )
                    }
                }
        }
        .environmentObject(router)
        .environmentObject(userPostsVMStore)
    }
}
