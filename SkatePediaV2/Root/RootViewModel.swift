//
//  RootViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation
import FirebaseAuth
import Combine

/// Defines a class that contains functions for the 'MainMenuView'.
@MainActor
final class RootViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    private var cancelables = Set<AnyCancellable>()
    
    @MainActor
    init() {
        // Detects if user is logged in
        setupSubscribers()
    }
    
    @MainActor
    private func setupSubscribers() {
        AuthenticationManager.shared.$userSession.sink { [weak self] userSession in
            self?.userSession = userSession
        }
        .store(in: &cancelables)
    }
}
