//
//  ErrorStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation

@MainActor
final class ErrorStore: ObservableObject {
    private let overlayManager: OverlayManager
    
    init(overlayManager: OverlayManager) {
        self.overlayManager = overlayManager
    }
    
    func present(
        _ error: Error,
        title: String? = nil,
        style: PopupStyle = .ok
    ) {
        let mappedError = mapToSPError(error: error)
        
        let appError = AppError(
            title: title ?? "Error",
            message: mappedError.errorDescription ?? "Something went wrong..."
        )
        
        _ = overlayManager.present(level: .blocking) { id in
            ErrorPopup(
                error: appError,
                style: style,
                onDismiss: {
                    self.overlayManager.dismiss(id: id)
                }
            )
        }
    }
}

//@MainActor
//final class ErrorStore: ObservableObject {
//    @Published var current: AppError?
//    @Published var activeSheetCount: Int = 0
//    
//    var isSheetActive: Bool {
//        activeSheetCount > 0
//    }
//    
//    func present(_ error: Error, title: String? = nil) {
//        print("PRESENT CALLED")
//        let spError = mapToSPError(error: error)
//        self.current = AppError(
//            title: title ?? "Error",
//            message: spError.errorDescription ?? "Something went wrong..."
//        )
//    }
//    
//    func present(title: String, message: String) {
//        self.current = AppError(title: title, message: message)
//    }
//    
//    func dismiss() {
//        current = nil
//    }
//}
