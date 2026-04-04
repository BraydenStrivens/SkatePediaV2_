//
//  CustomProgressBar.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/2/25.
//

import SwiftUI

struct CustomProgressBar: View {
    @Environment(\.colorScheme) var colorScheme
    var stance: TrickStance?
    var showHeader: Bool
    var totalTricks: Int
    var learnedTricks: Int
    var width: CGFloat
    var height: CGFloat = 20
    var progress: CGFloat
    
    var backgroundColor: Color = Color.primary.opacity(0.12)
    var startColor: Color = Color(hex: 0xb14604)
    var endColor: Color = Color(hex: 0xf3aa0c)
    var blotchColor: Color = Color(hex: 0xf5c151)
    
    @State private var animateEnergy: Bool = false
    @State private var completionPulse: Bool = false
    @State private var didTriggerCompletion: Bool = false
    @State private var noisePhase: CGFloat = 0
    
    
    init(
        stance: TrickStance? = nil,
        showHeader: Bool = true,
        totalTricks: Int,
        learnedTricks: Int,
        width: CGFloat = UIScreen.screenWidth * 0.5
    ) {
        self.stance = stance
        self.showHeader = showHeader
        self.totalTricks = totalTricks
        self.learnedTricks = learnedTricks
        self.width = width
        self.progress = CGFloat(Float(learnedTricks) / Float(totalTricks))
    }
    
    private var isComplete: Bool {
        progress >= 1
    }
    
    private var fillGradient: LinearGradient {
        LinearGradient(
            colors: [startColor, endColor],
            startPoint: animateEnergy ? .topLeading : .leading,
            endPoint: animateEnergy ? .bottomTrailing : .trailing
        )
    }
    
    var body: some View {
        HStack {
            if showHeader {
                Text("\(stance?.camalCase ?? "Total")")
                    .font(.headline)
                
                Spacer()
            }
            
            ZStack(alignment: .leading) {
                // Sunken background bar
                RoundedRectangle(cornerRadius: height, style: .continuous)
                    .fill(backgroundColor)
                    .frame(width: width, height: height)
                    .overlay(insetShadowTop)
                    .overlay(insetShadowBottom)
                
                // Raised progress bar
                if progress > 0 {
                    RoundedRectangle(cornerRadius: height, style: .continuous)
                        .fill(fillGradient)
                        .frame(width: width * progress, height: height)
                        .brightness(isComplete ? 0.2 : 0.1)
                        .animation(.easeInOut(duration: 0.4), value: isComplete)
                        .overlay(fillInsetHighlight)
                        .overlay(fillInsetShadow)
                        .overlay(glossOverlay)
                        .clipShape(
                            RoundedRectangle(cornerRadius: height, style: .continuous)
                        )
                        .scaleEffect(isComplete ? 1.03 : 1)
                        .animation(.spring(response: 0.45, dampingFraction: 0.6), value: progress)
                }
            }
            
            Spacer()
            
            Text("\(learnedTricks)/\(totalTricks)")
                .font(.headline)
        }
        .padding(.horizontal)
        .frame(height: height * 1.5)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 60)
                .repeatForever(autoreverses: true)
            ) {
                noisePhase = 1
            }
        }
        .onChange(of: progress) { _, newValue in
            if newValue >= 1, !didTriggerCompletion {
                didTriggerCompletion = true
                triggerCompletionSequence()
            }
        }
    }
    
    private func triggerCompletionSequence() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.45)) {
            completionPulse = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                completionPulse = false
            }
        }
    }
    
    private var insetShadowTop: some View {
        RoundedRectangle(cornerRadius: height, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.25),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 2
            )
            .blendMode(.overlay)
            .clipShape(
                RoundedRectangle(cornerRadius: height, style: .continuous)
            )
    }
    
    private var insetShadowBottom: some View {
        RoundedRectangle(cornerRadius: height, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.75)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 2
            )
            .blendMode(.overlay)
            .clipShape(
                RoundedRectangle(cornerRadius: height, style: .continuous)
            )
    }
    
    private var fillInsetHighlight: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.4),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .blendMode(.overlay)
    }
    
    private var fillInsetShadow: some View {
        LinearGradient(
            colors: [
                Color.clear,
                Color.black.opacity(0.35)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .blendMode(.multiply)
    }
    
    private var glossOverlay: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.35),
                Color.white.opacity(0.08),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .blendMode(.overlay)
    }
}
