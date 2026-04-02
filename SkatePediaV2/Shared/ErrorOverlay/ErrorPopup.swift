//
//  ErrorPopup.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/4/26.
//

import SwiftUI

struct ErrorPopup: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let error: AppError
    let style: ErrorPopupStyle
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
            Text(error.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(error.message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
            
            buttonSection
            
            if case let .autoDismiss(seconds) = style {
                progressBar(duration: seconds)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 24).protruded)
        .padding()
    }
    
    @ViewBuilder
    var buttonSection: some View {
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
    
    func retry(_ action: @escaping () async -> Void) {
        isRetrying = true
        
        Task {
            await action()
            
            await MainActor.run {
                isRetrying = false
                dismiss()
            }
        }
    }
    
    func progressBar(duration: Double) -> some View {
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
    
    func handleAutoDismissIfNeeded() {
        if case let .autoDismiss(seconds) = style {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                dismiss()
            }
        }
    }
    
    func dismiss() {
        animateIn = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}
