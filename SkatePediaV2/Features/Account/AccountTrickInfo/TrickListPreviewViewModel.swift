//
//  TrickListPreviewViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/10/25.
//

import Foundation
import SwiftUI

///
/// A class containing functions to fetch a user's trick list and sorting it based on the user's progress on each trick.
///
final class TrickListPreviewViewModel: ObservableObject {
    @Published private(set) var trickList: [Trick] = []
    @Published var requestState: RequestState = .idle

    @MainActor
    func fetchTrickList(userId: String, stance: TrickStance) async {
        do {
            requestState = .loading
            self.trickList = try await TrickListManager.shared.fetchTricksByStance(userId: userId, stance: stance)
            requestState = .success
            
        } catch {
            print("DEBUG: Failed to fetch user trick list by stance: \(error)")
            requestState = .failure(mapToSPError(error: error))
        }
    }
}
