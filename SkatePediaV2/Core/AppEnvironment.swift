//
//  AppEnvironment.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/14/26.
//

import Foundation

final class AppEnvironment: ObservableObject {
    let userStore: UserStore
    let userService: UserService
    
    let trickListStore: TrickListStore
    let trickListService: TrickListService
    
    let trickItemStore: TrickItemStore
    let trickItemService: TrickItemService
    
    let prosStore: ProsStore
    let prosService: ProsService
    
    let postStore: PostStore
    let postService: PostService
    
    let notificationStore: NotificationStore
    let notificationService: NotificationService
    
    let commentService: CommentService
    let relationshipService: RelationshipService
        
    init(
        userStore: UserStore,
        userService: UserService = .shared,
        trickListStore: TrickListStore,
        trickListService: TrickListService = .shared,
        trickItemStore: TrickItemStore,
        trickItemService: TrickItemService = .shared,
        prosStore: ProsStore,
        prosService: ProsService = .shared,
        postStore: PostStore,
        postService: PostService = .shared,
        notificationStore: NotificationStore,
        notificationService: NotificationService = .shared,
        commentService: CommentService = .shared,
        relationshipService: RelationshipService = .shared
    ) {
        self.userStore = userStore
        self.userService = userService
        self.trickListStore = trickListStore
        self.trickListService = trickListService
        self.trickItemStore = trickItemStore
        self.trickItemService = trickItemService
        self.prosStore = prosStore
        self.prosService = prosService
        self.postStore = postStore
        self.postService = postService
        self.notificationStore = notificationStore
        self.notificationService = notificationService
        self.commentService = commentService
        self.relationshipService = relationshipService
    }
    
    @MainActor
    func resetUserSpecificGlobalState() {
        userStore.stopListening()
        trickListStore.clear()
        trickItemStore.clear()
        prosStore.clear()
        postStore.clear()
        notificationStore.clear()
    }
}
