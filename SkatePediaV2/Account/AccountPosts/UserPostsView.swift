//
//  UserPostsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

///
/// Struct that displays a user's posts in their account view.
///
struct UserPostsView:  View {
    
    @ObservedObject var viewModel: UserAccountViewModel
    let user: User
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .center) {
                ForEach(viewModel.userPosts) { post in
                    PostCell(user: user, post: post)
                    .padding(.horizontal, 15)
                }
            }
        }
    }
}
