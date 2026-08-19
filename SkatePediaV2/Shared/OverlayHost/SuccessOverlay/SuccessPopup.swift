//
//  SuccessPopup.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/4/26.
//

import SwiftUI

struct SuccessPopup: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    let appSuccess: AppSuccess
    let onDismiss: () -> Void
    
    @State private var animateIn = false
    @State private var progress: CGFloat = 1.0
    @State private var isRetrying = false
    
    private let seconds: Double = 3.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            popupCard
                .scaleEffect(animateIn ? 1 : 0.92)
                .opacity(animateIn ? 1 : 0)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: animateIn)
        }
        .onAppear {
            animateIn = true
            handleAutoDismiss()
        }
    }
    
    private var popupCard: some View {
        VStack(spacing: 20) {
            if let title = appSuccess.title {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            
            Text(appSuccess.message)
                .multilineTextAlignment(.center)
                .foregroundStyle(colorScheme == .dark ? .gray : Color(.darkGray))
                        
            progressBar(duration: seconds)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? .ultraThinMaterial : .thinMaterial)
        .cornerRadius(20)
        .padding()
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
    
    private func handleAutoDismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            dismiss()
        }
    }
    
    private func dismiss() {
        animateIn = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

