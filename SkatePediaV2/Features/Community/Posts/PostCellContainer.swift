//
//  PostCellContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import SwiftUI

struct PostCellContainer: View {
    @EnvironmentObject var session: SessionContainer
    @EnvironmentObject var errorStore: ErrorStore
    
    let user: User
    let post: Post
    
    var body: some View {
        let viewModel = PostCellViewModel(
            videoUrl: post.videoData.videoUrl,
            useCases: session.post,
            errorStore: errorStore
        )
        
        PostCell(
            user: user,
            post: post,
            viewModel: viewModel
        )
    }
}
