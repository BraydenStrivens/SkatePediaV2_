//
//  SwipableNotificationCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/28/26.
//

import SwiftUI

struct SwipableNotificationCell: View {

    @Binding var openID: String?
    let notification: Notification
    let user: User
    let onDelete: () -> Void
        
    private let buttonSize: CGFloat = 35
    private let actionWidth: CGFloat = 70
    
    @State private var offset: CGFloat = 0
    @State private var startOffset: CGFloat = 0
    @State private var isDraggingHorizontally: Bool = false
    @State private var actionLoading: Bool = false
    
    init(
        notification: Notification,
        user: User,
        openID: Binding<String?>,
        onDelete: @escaping () -> Void
    ) {
        self.notification = notification
        self.user = user
        _openID = openID
        self.onDelete = onDelete
    }
    
    private var isOpen: Bool {
        openID == notification.id
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            deleteButton
            
            NotificationCell(
                user: user,
                notification: notification
            )
            .background {
                if notification.seen {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(offset != 0
                              ? Color(.tertiarySystemFill)
                              : Color.clear
                        )
                } else {
                    RoundedRectangle(cornerRadius: offset != 0 ? 12 : 0)
                        .fill(Color(.tertiarySystemFill))
                        .stroke(Color.button.opacity(0.2), lineWidth: 1)
                }
            }
            .offset(x: offset)
            .simultaneousGesture(dragGesture)
            .onChange(of: openID) { _, newValue in
                if newValue != notification.id {
                    withAnimation(.bouncy(duration: 0.2)) {
                        close()
                    }
                }
            }
        }
        .clipped()
    }
    
    private var deleteButton: some View {
        HStack {
            Spacer()

            Button {
                actionLoading = true
                onDelete()
            } label: {
                Group {
                    if actionLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.red)
                )
            }
            .padding(.trailing, 12)
            .frame(width: max(-offset, 0), alignment: .trailing)
            .clipped()
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20)
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
                
                if predicted < -buttonSize * 0.4 {
                    open()
                } else {
                    close()
                }
            }
    }
    
    private func open() {
        withAnimation(.easeOut(duration: 0.2)) {
            openID = notification.id
            offset = -actionWidth
            startOffset = offset
        }
    }
    
    private func close() {
        withAnimation(.easeOut(duration: 0.2)) {
            offset = 0
            startOffset = 0

            if openID == notification.id {
                openID = nil
            }
        }
    }
}

