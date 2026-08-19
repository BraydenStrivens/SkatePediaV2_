//
//  TrickStanceTabView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/18/26.
//

import SwiftUI

struct TrickStanceTabView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedStance: TrickStance = .regular
    @State private var transitionDirection: (insertion: Edge, removal: Edge) = (.trailing, .leading)
    
    let content: (TrickStance) -> Content
    
    init(@ViewBuilder content: @escaping (TrickStance) -> Content) {
        self.content = content
    }
    
    
    var body: some View {
        VStack {
            tabSelector
            
            content(selectedStance)
                .id(selectedStance)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: transitionDirection.insertion),
                        removal: .move(edge: transitionDirection.removal)
                    )
                )
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(TrickStance.allCases) { stance in
                let isCurrentTab = selectedStance == stance
                
                Text(stance.camalCase)
                    .font(.body)
                    .fontWeight(isCurrentTab ? .semibold : .regular)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background {
                        Rectangle()
                            .fill(colorScheme == .dark
                                  ? (isCurrentTab ? Color(.systemGray5) : .clear)
                                  : (isCurrentTab ? Color(.systemBackground) : .clear)
                            )
                            .shadow(color: colorScheme == .dark
                                    ? .clear
                                    : .black.opacity(0.4), radius: 4, y: 3
                            )
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(isCurrentTab ? Color.accent : Color.clear)
                                    .frame(height: 2)
                            }
                    }
                    .onTapGesture {
                        selectStanceTab(newStance: stance)
                    }
            }
        }
    }
    
    private func selectStanceTab(newStance: TrickStance) {
        guard newStance != selectedStance else { return }
        
        if newStance.index > selectedStance.index {
            transitionDirection = (.trailing, .leading)
        } else {
            transitionDirection = (.leading, .trailing)
        }
        
        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
            selectedStance = newStance
        }
    }
}
