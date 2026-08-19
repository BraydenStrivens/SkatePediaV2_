//
//  FriendRequestPopup.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/20/26.
//

import SwiftUI

struct RelationshipRequestPopup: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let sender: User
    let style: PopupStyle
    let onDismiss: () -> Void
    
    @State private var animateIn = false
    @State private var progress: CGFloat = 1.0
    @State private var isRetrying = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    if case .autoDismiss(_) = style { }
                    else { dismiss() }
                }
            
            popupCard
                .scaleEffect(animateIn ? 1 : 0.92)
                .opacity(animateIn ? 1 : 0)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: animateIn)
        }
        .onAppear {
            animateIn = true
            handleAutoDismissIfNeeded()
        }
    }
    
    private var popupCard: some View {
        VStack(spacing: 20) {
            Group {
                Text(sender.username)
                    .fontWeight(.semibold)
                + Text("sent you a friend request!")
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(colorScheme == .dark ? .gray : Color(.darkGray))
            
            buttonSection
            
            if case let .autoDismiss(seconds) = style {
                progressBar(duration: seconds)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding()
    }
    
    @ViewBuilder
    private var buttonSection: some View {
        switch style {
        case .ok:
            Button("OK") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.button)
            
        case .autoDismiss(_):
            EmptyView()
            
        case .retry(let action):
            Button {
                retry(action)
            } label: {
                if isRetrying {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Text("Retry")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRetrying)
        }
    }
    
    private func retry(_ action: @escaping () async -> Void) {
        isRetrying = true
        
        Task {
            await action()
            
            await MainActor.run {
                isRetrying = false
                dismiss()
            }
        }
    }
    
    private func progressBar(duration: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                
                Capsule()
                    .fill(Color.button)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 3)
        .onAppear {
            withAnimation(.linear(duration: duration)) {
                progress = 0
            }
        }
    }
    
    private func handleAutoDismissIfNeeded() {
        if case let .autoDismiss(seconds) = style {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                dismiss()
            }
        }
    }
    
    private func dismiss() {
        animateIn = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}
