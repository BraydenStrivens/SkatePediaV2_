//
//  CustomRefreshableScrollView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/13/26.
//

import SwiftUI

private struct PullOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CustomRefreshableScrollView<Content: View, Header: View>: View {
    let onRefresh: () async -> Void
    let header: (CGFloat, Bool) -> Header
    let content: Content
    
    @State private var isRefreshing: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    private let triggerDistance: CGFloat = 110
    
    init(
        @ViewBuilder header: @escaping (CGFloat, Bool) -> Header,
        @ViewBuilder content: () -> Content,
        onRefresh: @escaping () async -> Void
    ) {
        self.header = header
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    struct ScrollOffsetReader: View {
        var body: some View {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ScrollOffsetKey.self,
                                value: proxy.frame(in: .named("scroll")).origin.y)
            }
            .frame(height: 0)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScrollOffsetReader()
                
                header(progress, isRefreshing)
                    .frame(height: isRefreshing ? 80 : dragOffset)
                
                content
            }
            
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetKey.self) { y in
            guard !isRefreshing else { return }
            
            let overscroll = max(0, y)
            dragOffset = overscroll
            
            if overscroll > triggerDistance {
                beginRefresh()
            }
        }
    }
    
    private var progress: CGFloat {
        min(1, dragOffset / triggerDistance)
    }
    
    private func beginRefresh() {
        isRefreshing = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        Task {
            await onRefresh()
            withAnimation(.spring()) {
                isRefreshing = false
                dragOffset = 0
            }
        }
    }
}

struct LiquidRefreshHeader: View {
    let progress: CGFloat
    let isRefreshing: Bool
    
    var body: some View {
        ZStack {
            if isRefreshing {
                ProgressView()
                    .scaleEffect(1.3)
            } else {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 28, height: 28)
                    .opacity(progress)
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.top], 12)
    }
}
