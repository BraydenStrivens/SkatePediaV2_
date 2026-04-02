//
//  CommentReplies.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/23/26.
//

import SwiftUI

struct CommentRepliesView: View {
    @EnvironmentObject var commentStore: CommentStore
    @EnvironmentObject private var commentsViewVM: CommentsViewModel
    
    @Environment(\.colorScheme) private var colorScheme
        
    let baseComment: Comment
    let user: User
    @Binding var openCommentID: String?
    
    var replies: [Comment] {
        commentStore.replies(for: baseComment.id)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                CommentShowRepliesConnectorLine(
                    photoBottomY: 0,
                    buttonCenterX: UIScreen.screenWidth / 2
                )
                .stroke(Color(.systemGray5), lineWidth: 1)
                .offset(x: 25)
                
                showHideRepliesButton
            }
            
            if commentsViewVM.showReplies(for: baseComment.id) {
                repliesSection
            }
        }
    }
    
    var showHideRepliesButton: some View {
        Button {
            withAnimation(.smooth) {
                commentsViewVM.toggleReplies(
                    for: baseComment.id,
                    from: baseComment.postId
                )
            }
        } label: {
            if commentsViewVM.showReplies(for: baseComment.id){
                Text("Hide Replies")
            } else {
                Text("Show replies (\(baseComment.replyCount!))")
            }
        }
        .padding(.horizontal, 6)
        .background(colorScheme == .dark
                    ? Color(.systemGray6)
                    : Color(.systemBackground)
        )
        .foregroundStyle(.gray)
        .font(.caption)
    }
    
    var repliesSection: some View {
        Group {
            if replies.isEmpty {
                EmptyView()
                
            } else {
                ForEach(replies) { reply in
                    LazyVStack(spacing: 20) {
                        SwipeableCommentCell(
                            comment: reply,
                            openID: $openCommentID,
                            currentUid: user.userId,
                            onDelete: { comment in
                                Task {
                                    await commentsViewVM.deleteReplyComment(reply: comment)
                                }
                            },
                            onReport: { comment in
                                Task {
                                    await commentsViewVM.reportComment(
                                        comment: comment,
                                        userId: user.userId
                                    )
                                }
                            }
                        )
                    }
                }
                if commentsViewVM.replyUIStatesById[baseComment.id]?.isLoading == true {
                    ProgressView()
                        .progressViewStyle(.circular)
                    
                } else if commentsViewVM.replyUIStatesById[baseComment.id]?.hasMore == true {
                    ZStack {
                        Divider()
                            .padding(.leading, 40)
                        
                        Button {
                            Task {
                                await commentsViewVM.fetchReplies(
                                    postId: baseComment.postId,
                                    baseCommentId: baseComment.id
                                )
                            }
                        } label: {
                            Text("Show more")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 6)
                        .background(colorScheme == .dark
                                    ? Color(.systemGray6)
                                    : Color(.systemBackground)
                        )
                    }
                }
            }
        }
    }
}
