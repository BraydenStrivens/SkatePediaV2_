//
//  CommunityRootView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/15/26.
//

import SwiftUI

struct CommunityRootView: View {
    @EnvironmentObject private var postStore: PostStore
    @EnvironmentObject private var errorStore: ErrorStore
    @EnvironmentObject private var notificationStore: NotificationStore
    
    @StateObject private var router = CommunityRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            CommunityBuilder.build(postStore: postStore, errorStore: errorStore)
                .navigationDestination(for: CommunityRoute.self) { route in
                    switch route {
                    case .accountSearch(let currentUser):
                        AccountSearchBuilder.build(currentUser: currentUser, errorStore: errorStore)
                        
                    case .userAccount(let currentUser, let otherUser):
                        UserAccountBuilder.build(currentUser: currentUser, otherUser: otherUser, errorStore: errorStore)
                        
                    case .notifications(let currentUser):
                        NotificationBuilder.build(user: currentUser, errorStore: errorStore, notificationStore: notificationStore)
                        
                    case .userChats:
                        VStack { }
                    case .userChat:
                        VStack { }
                    case .selectTrick(let user):
                        SelectTrickView(user: user)
                        
                    case .selectTrickItem(let user, let trick):
                        SelectTrickItemView(user: user, trick: trick)
                        
                    case .addPost(let user, let trick, let trickItem):
                        AddPostBuilder.build(
                            user: user,
                            trick: trick,
                            trickItem: trickItem,
                            postStore: postStore,
                            errorStore: errorStore,
                            onSuccess: {
                                router.reset()
                            }
                        )
                    }
                }
        }
        .environmentObject(router)
    }
}
