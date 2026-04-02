//
//  UserPostPreviewCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 9/26/25.
//

import SwiftUI
import Firebase

struct UserPostPreviewCell: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var post: Post
    var postOwner: User
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            CircularProfileImageView(photoUrl: postOwner.profilePhoto?.photoUrl, size: .medium)
            
            VStack(alignment: .leading) {
                HStack(spacing: 20) {
                    Text("@\(postOwner.username)")
                        .font(.headline)
                        .bold()
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Group {
                        if postOwner.settings.trickSettings.useTrickAbbreviations {
                            Text(post.trickData.abbreviatedName)
                        } else {
                            Text(post.trickData.name)
                        }
                    }
                    .font(.subheadline)
                }
                
                HStack(alignment: .bottom) {
                    Text(post.content)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                    Text(post.dateCreated.timeAgoString())
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
        }
        .padding(10)
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 14).protruded)
    }
}
