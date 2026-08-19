//
//  SwipeContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/22/26.
//

import SwiftUI



struct SwipeableCommentCell: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: CommunityRouter
    @EnvironmentObject private var appEnv: AppEnvironment
    @EnvironmentObject private var errorStore: ErrorStore
    @EnvironmentObject var commentsViewVM: CommentsViewModel
    
    let comment: Comment
    let id: String
    let currentUser: User

    @Binding var openID: String?
    
    let onDelete: (Comment) -> Void
        
    private let buttonSize: CGFloat = 40
    private let buttonFrameWidth: CGFloat = 50
    
    @State private var offset: CGFloat = 0
    @State private var startOffset: CGFloat = 0
    @State private var isDraggingHorizontally: Bool = false
    @State private var actionLoading: Bool = false
    @State private var toggleReportSheet: Bool = false
    
    init(
        comment: Comment,
        openID: Binding<String?>,
        currentUser: User,
        onDelete: @escaping (Comment) -> Void
    ) {
        self.comment = comment
        self.id = comment.id
        self.currentUser = currentUser
        self._openID = openID
        self.onDelete = onDelete
    }
    
    private var isOpen: Bool {
        openID == id
    }
    
    private var isReply: Bool {
        comment.isReply
    }
    
    private var canDelete: Bool {
        currentUser.userId == comment.userData.userId ||
        currentUser.userId == comment.postOwnerUid
    }
    
    private var canReport: Bool {
        currentUser.userId != comment.userData.userId
    }
    
    private var visibleButtons: [CommentSwipeAction] {
        var actions: [CommentSwipeAction] = []
        
        if canReport {
            actions.append(.report)
        }
        if canDelete {
            actions.append(.delete)
        }
        
        return actions
    }
    
    private var actionWidth: CGFloat {
        CGFloat(visibleButtons.count) * buttonFrameWidth
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            
            HStack(spacing: 0) {
                ForEach(visibleButtons, id: \.self) { action in
                    actionButton(for: action)
                }
            }
            .frame(width: max(-offset, 0), alignment: .trailing)
            .clipped()

            
            commentBody
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(offset != 0
                              ? Color(.tertiarySystemFill)
                              : Color.clear
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .offset(x: offset)
                .padding(.leading, comment.isReply ? 40 : 10)
                .simultaneousGesture(dragGesture)
                .onChange(of: openID) { _, newValue in
                    if newValue != id {
                        withAnimation(.bouncy(duration: 0.2)) {
                            close()
                        }
                    }
                }
        }
        .clipped()
        .spSheet(isPresented: $toggleReportSheet, detent: .full) {
            ReportItemSheetBuilder.build(
                currentUid: currentUser.userId,
                otherUid: comment.userData.userId,
                reportType: .comment(comment),
                appEnv: appEnv,
                errorStore: errorStore
            )
        }
    }
    
    private var commentBody: some View {
        HStack(alignment: .top, spacing: 15) {
            CircularProfileImageView(photoUrl: comment.userData.photoUrl, size: .large)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 15) {
                    Text(comment.userData.username)
                        .font(.headline)
                    
                    Text(comment.dateCreated.timeAgoString())
                        .foregroundColor(Color(uiColor: .systemGray2))
                        .font(.caption)
                }
                
                if let replyingToData = comment.replyingToData {
                    Text("@\(replyingToData.ownerUsername) \(comment.content)")
                } else {
                    Text(comment.content)
                        .font(.subheadline)
                }
                
                HStack(spacing: 20) {
                    // Sets the comment to be replied to
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            commentsViewVM.replyToComment = comment
                            commentsViewVM.isReply = true
                        }
                    } label: {
                        Text("Reply")
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .foregroundStyle(.gray)
                .font(.caption)
            }
            .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(6)
//        .contentShape(Rectangle())
//        .onTapGesture {
//            Task {
//                guard let commentOwner = try? await appEnv.userService
//                    .fetchUser(userId: comment.userData.userId)
//                else { return }
//                
//                router.push(.userAccount(
//                    currentUser: currentUser,
//                    otherUser: commentOwner)
//                )
//            }
//        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onChanged { value in
                let horizontal = abs(value.translation.width)
                let vertical = abs(value.translation.height)
                
                if !isDraggingHorizontally {
                    if horizontal > vertical {
                        isDraggingHorizontally = true
                    } else {
                        return
                    }
                }
                
                guard isDraggingHorizontally else { return }
                
                let newOffset = startOffset + value.translation.width
                
                offset = min(0, max(-actionWidth, newOffset))
            }
            .onEnded { value in
                defer { isDraggingHorizontally = false }
                guard isDraggingHorizontally else { return }
                
                let predicted = startOffset + value.predictedEndTranslation.width
                
                if predicted < -actionWidth * 0.4 {
                    open()
                } else {
                    close()
                }
            }
    }
    
    private func open() {
        withAnimation(.easeOut(duration: 0.2)) {
            openID = id
            offset = -actionWidth
            startOffset = offset
        }
    }
    
    private func close() {
        withAnimation(.easeOut(duration: 0.2)) {
            offset = 0
            startOffset = 0
            
            if openID == id {
                openID = nil
            }
        }
    }
    
    private func actionButton(for action: CommentSwipeAction) -> some View {
        Button {
            actionLoading = true
            handle(action)
        } label: {
            VStack {
                if actionLoading {
                    ProgressView()
                    
                } else {
                    Image(systemName: action.systemImage)
                }
            }
            .foregroundColor(.white)
            .frame(width: buttonSize, height: buttonSize)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(action.color)
            )
        }
        .frame(maxHeight: .infinity)
        .frame(width: buttonFrameWidth)
    }
    
    private func handle(_ action: CommentSwipeAction) {
        switch action {
        case .delete:
            onDelete(comment)
            
        case .report:
            toggleReportSheet = true
        }
        
        actionLoading = false
    }
}
