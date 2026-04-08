//
//  TrickListPreviewViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/10/25.
//

import Foundation
import SwiftUI

/// Manages fetching and presenting a preview of a user's trick list.
///
/// This class is responsible for retrieving a user's tricks filtered by stance
/// and updating the request state to reflect loading, success, or failure.
/// It is typically used to display a user's trick list progress.
final class TrickListPreviewViewModel: ObservableObject {
    @Published private(set) var trickList: [Trick] = []
    @Published var requestState: RequestState = .idle

    /// Fetches the user's trick list for a given stance.
    ///
    /// Updates the `trickList` and `requestState` based on the result of the request.
    ///
    /// - Parameters:
    ///   - userId: The unique identifier of the user whose tricks are being fetched.
    ///   - stance: The stance used to filter the trick list.
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
