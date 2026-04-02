//
//  SwipeContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/22/26.
//

import SwiftUI



struct SwipeableCommentCell: View {
    @EnvironmentObject var commentsViewVM: CommentsViewModel
    
    let comment: Comment
    let id: String
    let currentUid: String

    @Binding var openID: String?
    
    let onDelete: (Comment) -> Void
    let onReport: (Comment) -> Void
        
    private let buttonWidth: CGFloat = 70
    
    @State private var offset: CGFloat = 0
    @State private var startOffset: CGFloat = 0
    @State private var isDraggingHorizontally: Bool = false
    @State private var actionLoading: Bool = false
    
    init(
        comment: Comment,
        openID: Binding<String?>,
        currentUid: String,
        onDelete: @escaping (Comment) -> Void,
        onReport: @escaping (Comment) -> Void
    ) {
        self.comment = comment
        self.id = comment.id
        self.currentUid = currentUid
        self._openID = openID
        self.onDelete = onDelete
        self.onReport = onReport
    }
    
    private var isOpen: Bool {
        openID == id
    }
    
    private var isReply: Bool {
        comment.isReply
    }
    
    private var canDelete: Bool {
        currentUid == comment.userData.userId ||
        currentUid == comment.postOwnerUid
    }
    
    private var canReport: Bool {
        currentUid != comment.userData.userId &&
        currentUid != comment.postOwnerUid
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
        CGFloat(visibleButtons.count) * buttonWidth
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if offset < 0 {
                HStack(spacing: 0) {
                    ForEach(visibleButtons, id: \.self) { action in
                        actionButton(for: action)
                    }
                }
                .frame(width: actionWidth)
            }
            
            commentBody
                .background(.clear)
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
        .contentShape(Rectangle())
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
        openID = id
        offset = -actionWidth
        startOffset = offset
    }
    
    private func close() {
        offset = 0
        startOffset = 0
        if openID == id {
            openID = nil
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
                        .progressViewStyle(.circular)
                    
                } else {
                    Image(systemName: action.systemImage)
                    Text(action.text)
                        .font(.caption)
                }
            }
            .foregroundColor(.white)
        }
        .frame(width: buttonWidth)
        .frame(maxHeight: .infinity)
        .background(action.color)
    }
    
    private func handle(_ action: CommentSwipeAction) {
        switch action {
        case .delete: onDelete(comment)
        case .report: onReport(comment)
        }
        actionLoading = false
        close()
    }
}
