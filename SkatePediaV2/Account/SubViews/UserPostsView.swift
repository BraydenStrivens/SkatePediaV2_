//
//  UserPostsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

struct UserPostsView:  View {
    
    @ObservedObject var viewModel: AccountViewModel
    let user: User
    
    var body: some View {
        if viewModel.userPosts.isEmpty {
            VStack(alignment: .center) {
                Spacer()
                HStack {
                    Spacer()
                    Text("'\(user.username)' has no posts.")
                        .font(.title3)
                        .foregroundColor(.primary)
                    Spacer()
                }
                Spacer()
            }
        } else {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(viewModel.userPosts) { post in
                        PostCell(posts: $viewModel.userPosts,
                                 post: post
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
