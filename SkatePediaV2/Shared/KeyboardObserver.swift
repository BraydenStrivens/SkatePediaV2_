//
//  KeyboardObserver.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/23/26.
//

import Foundation
import SwiftUI
import Combine

/// Observes keyboard appearance and updates a published height value.
///
/// This class listens for keyboard show and hide notifications and updates
/// the `height` property to match the keyboard's current height. It can
/// be used in SwiftUI views to adjust layouts when the keyboard appears.
@MainActor
class KeyboardObserver: ObservableObject {
    
    /// The current height of the keyboard. Updates automatically when the keyboard shows or hides.
    @Published var height: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the observer and subscribes to keyboard notifications.
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        
        // Merge show and hide notifications
        willShow
            .merge(with: willHide)
            .sink { notification in
                if notification.name == UIResponder.keyboardWillHideNotification {
                    self.height = 0
                } else {
                    let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                    self.height = frame?.height ?? 0
                }
            }
            .store(in: &cancellables)
    }
}
