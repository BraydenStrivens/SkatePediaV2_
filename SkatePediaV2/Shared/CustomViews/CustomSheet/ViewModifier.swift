//
//  ViewModifier.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/4/26.
//

import SwiftUI

struct SPSheetModifier<SheetContent: View>: ViewModifier {
    @EnvironmentObject private var overlayManager: OverlayManager
    
    @Binding var isPresented: Bool
    
    let detent: SheetDetent
    let content: () -> SheetContent
    
    @State private var overlayID: UUID?
    @State private var dismissAction: (() -> Void)?
    
    func body(content base: Content) -> some View {
        base
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    presentSheet()
                } else {
                    dismissSheet()
                }
            }
    }
    
    func presentSheet() {
        overlayID = overlayManager.present(level: .sheet, content: { id in
            SPSheetContainer(
                id: id,
                detent: detent,
                content: content,
                onDismissComplete: {
                    overlayManager.dismiss(id: id)
                    overlayID = nil
                    isPresented = false
                },
                registerDismiss: { dismiss in
                    dismissAction = dismiss
                }
            )
        })
    }
    
    func dismissSheet() {
        if let id = overlayID {
            overlayManager.dismiss(id: id)
            overlayID = nil
        }
    }
}

extension View {
    func spSheet<Content: View>(
        isPresented: Binding<Bool>,
        detent: SheetDetent = .full,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            SPSheetModifier(
                isPresented: isPresented,
                detent: detent,
                content: content
            )
        )
    }
}
