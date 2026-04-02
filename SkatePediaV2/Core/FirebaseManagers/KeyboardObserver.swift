//
//  KeyboardObserver.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/23/26.
//

import Foundation
import SwiftUI
import Combine

class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        
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
