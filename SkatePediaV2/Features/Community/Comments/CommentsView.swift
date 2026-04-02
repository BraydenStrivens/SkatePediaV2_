//
//  CommentsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

/// Displays the comments for a post. Fetches the comments in fixed batches and fetched more when the last comment
/// appears. Contains a text field and upload button for users to upload new comments. If a comment is a reply, displays
/// information about the comment being replied to above the text field.
struct CommentsView: View {
    @EnvironmentObject var commentStore: CommentStore
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var keyboard = KeyboardObserver()
    @State private var openCommentID: String?
    @FocusState private var isFocused: Bool
    
    @ObservedObject var viewModel: CommentsViewModel
    let user: User
    let post: Post
    
    init(
        user: User,
        post: Post,
        viewModel: CommentsViewModel
    ) {
        self.user = user
        self.post = post
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            switch viewModel.initialFetchState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                GeometryReader { geo in
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                commentsSection
                            }
                            .frame(minHeight: geo.size.height, alignment: .top) // ✅ FIX 1
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .onTapGesture {
                            isFocused = false
                        }
                        .onChange(of: commentStore.baseComments.first?.commentId) { _, _ in
                            if let firstId = commentStore.baseComments.first?.commentId {
                                withAnimation {
                                    proxy.scrollTo(firstId, anchor: .top)
                                }
                            }
                        }
                        .safeAreaInset(edge: .bottom) {
                            inputBar(proxy: proxy)
                        }
                    }
                }
                
            case .failure(let sPError):
                ContentUnavailableView(
                    "Error Fetching Comments",
                    systemImage: "exclamationmark.triangle",
                    description: Text(sPError.errorDescription ?? "Something went wrong...")
                )
                .frame(maxHeight: .infinity, alignment: .center)
            }
        }
        .task {
            await viewModel.initialBaseCommentFetch(for: post.postId)
        }
    }
    
    var commentsSection: some View {
        Group {
            if commentStore.baseComments.isEmpty {
                ContentUnavailableView(
                    "No Comments",
                    systemImage: "list.bullet.rectangle.portrait",
                    description: Text("Help this user learn their trick and be the first to comment.")
                )

            } else {
                ForEach(commentStore.baseComments) { baseComment in
                    SwipeableCommentCell(
                        comment: baseComment,
                        openID: $openCommentID,
                        currentUid: user.userId,
                        onDelete: { comment in
                            Task {
                                await viewModel.deleteBaseComment(comment: comment)
                            }
                        },
                        onReport: { comment in
                            Task {
                                await viewModel.reportComment(
                                    comment: comment,
                                    userId: user.userId
                                )
                            }
                        }
                    )
                    .environmentObject(viewModel)
                    .padding(.top, 8)
                    .id(baseComment.commentId)
                    .task {
                        if !viewModel.fetchingMoreBaseComments,
                           baseComment == commentStore.baseComments.last! {
                            await viewModel.fetchMoreBaseComments(postId: post.postId)
                        }
                    }

                    if (baseComment.replyCount ?? 0) > 0 {
                        CommentRepliesView(
                            baseComment: baseComment,
                            user: user,
                            openCommentID: $openCommentID
                        )
                        .environmentObject(viewModel)
                    }
                }

                if viewModel.fetchingMoreBaseComments {
                    CustomProgressView(placement: .center)
                }
            }
        }
    }
    
    func inputBar(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 8) {
            
            if let replyingTo = viewModel.replyToComment {
                replyBanner(replyingTo)
            }
            
            HStack(alignment: .center) {
                TextField(
                    viewModel.isReply ? "Add Reply" : "Add Comment",
                    text: $viewModel.newContent,
                    axis: .vertical
                )
                .autocorrectionDisabled()
                .padding(10)
                .lineLimit(1...6)
                .focused($isFocused)
                
                Button {
                    Task {
                        await viewModel.uploadComment(user: user, post: post)
                    }
                } label: {
                    if viewModel.isUploading {
                        ProgressView()
                        
                    } else {
                        Image(systemName: "plus")
                            .foregroundColor(
                                viewModel.newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? .gray.opacity(0.6)
                                : .gray
                            )
                    }
                }
                .padding(10)
                .disabled(viewModel.newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        viewModel.newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? .gray.opacity(0.6)
                        : .primary
                    )
            )
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
        .animation(.easeInOut(duration: 0.2), value: viewModel.newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    func replyBanner(_ replyingTo: Comment) -> some View {
        HStack {
            let replyText = "Reply to @\(replyingTo.userData.username) \(replyingTo.content.prefix(20))"
            
            Text(replyText)
                .font(.caption)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                withAnimation {
                    viewModel.replyToComment = nil
                    viewModel.isReply = false
                }
            } label: {
                Image(systemName: "x.circle")
            }
        }
        .foregroundColor(.primary.opacity(0.7))
        .padding(.horizontal)
    }
    
    func scrollToTop(proxy: ScrollViewProxy) {
        guard let firstId = commentStore.baseComments.first?.commentId else { return }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            proxy.scrollTo(firstId, anchor: .top)
        }
    }
}
