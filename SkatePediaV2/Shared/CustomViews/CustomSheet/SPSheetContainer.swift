//
//  SPSheetContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/4/26.
//

import SwiftUI

struct SPSheetContainer<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let id: UUID
    let detent: SheetDetent
    let content: () -> Content
    let onDismissComplete: () -> Void
    let registerDismiss: (@escaping () -> Void) -> Void
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = UIScreen.screenHeight
    @State private var backgroundOpacity: Double = 0
    
    var sheetHeight: CGFloat {
        detent.height(for: UIScreen.screenHeight)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            sheetBody
                .offset(y: currentOffset + dragOffset)
                .gesture(dragGesture)
                .transition(.move(edge: .bottom))
        }
//        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            registerDismiss {
                dismiss()
            }
            
            withAnimation(.easeInOut(duration: 0.1)) {
                backgroundOpacity = 0.2
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                currentOffset = 0
            }
        }
    }
    
    var sheetBody: some View {
        VStack(spacing: 0) {
            header
            
            content()
                .frame(maxHeight: .infinity)
                .environment(\.spSheetDismiss, dismiss)
        }
//        .frame(height: sheetHeight)
        .frame(maxHeight: sheetHeight)
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 24).protruded)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(radius: 20)
    }
    
    var header: some View {
        HStack {
            Spacer()
            Capsule()
                .frame(width: 40, height: 5)
                .tint(.gray)
                .padding(.vertical, 6)
            Spacer()
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                if value.translation.height > 0 {
                    state = value.translation.height
                }
            }
            .onEnded { value in
                if value.translation.height > (sheetHeight / 3) {
                    currentOffset += value.translation.height
                    dismiss()
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        currentOffset = 0
                    }
                }
            }
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            backgroundOpacity = 0
            currentOffset = UIScreen.screenHeight
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismissComplete()
        }
    }
}

