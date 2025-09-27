//
//  UserPostPreviewCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 9/26/25.
//

import SwiftUI
import Firebase

struct UserPostPreviewCell: View {
    var post: Post
    var postOwner: User
    @State var trick: Trick?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Text("@\(postOwner.username)")
                    .font(.headline)
                    .bold()
                    .lineLimit(1)
                          
                Spacer()
                
                if let trick {
                    Text(trick.name)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text(post.dateCreated.timeSinceUploadString())
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            CollapsableTextView(post.content, lineLimit: 2)
                .multilineTextAlignment(.leading)
            
            Divider()
        }
        .padding(10)
        .onAppear {
            Task {
                trick = try await TrickListManager.shared.fetchTricksById(userId: postOwner.userId, trickId: post.trickId)
            }
        }
    }
}
