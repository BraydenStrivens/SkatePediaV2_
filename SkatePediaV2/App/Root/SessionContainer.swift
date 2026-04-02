//
//  SessionContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation

@MainActor
final class SessionContainer: ObservableObject {
    let userStore: UserStore
    let trickListStore: TrickListStore
    let trickItemStore: TrickItemStore
    let postStore: PostStore
    
    let user: UserUseCases
    let trickList: TrickListUseCases
    let trickItem: TrickItemUseCases
    let post: PostUseCases
    
    init() {
        let userStore = UserStore()
        let trickListStore = TrickListStore()
        let trickItemStore = TrickItemStore()
        let postStore = PostStore()
        
        self.userStore = userStore
        self.trickListStore = trickListStore
        self.trickItemStore = trickItemStore
        self.postStore = postStore
        
        let userService = UserService.shared
        let trickListService = TrickListService.shared
        let trickItemService = TrickItemService.shared
        let postService = PostService.shared
        
        self.user = UserUseCases(
            userStore: userStore
        )
        
        self.trickList = TrickListUseCases(
            trickListStore: trickListStore,
            trickItemStore: trickItemStore,
            postStore: postStore,
            service: trickListService
        )
        
        self.trickItem = TrickItemUseCases(
            trickItemStore: trickItemStore,
            trickListStore: trickListStore,
            postStore: postStore,
            service: trickItemService
        )
        
        self.post = PostUseCases(
            postStore: postStore,
            trickItemStore: trickItemStore,
            service: postService
        )
    }
}
