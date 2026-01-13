//
//  UserPostsPreviewView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 9/26/25.
//

import SwiftUI

struct UserPostsPreviewView: View {
    @ObservedObject var viewModel: UserAccountViewModel
    var user: User
    
    var body: some View {
        if let user = viewModel.user {
            ScrollView {
                ForEach(viewModel.userPosts) { post in
                    CustomNavLink(destination: UserPostsView(viewModel: viewModel, user: user)
                        .customNavBarItems(title: "\(user.username)'s Posts", subtitle: "", backButtonHidden: false)) {
                        UserPostPreviewCell(
                            post: post,
                            postOwner: user
                        )
                    }
                        .foregroundColor(.primary)
                }
            }
        }
    }
}
