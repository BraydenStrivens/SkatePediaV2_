//
//  SelectTrickViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/15/26.
//

import Foundation

/// Custom truct for holding all the tricks for a specific stance. Used so that its array of tricks can be looped over in a ForEach loop.
///
/// - Parameters:
///  - tricks: An array of 'Trick' objects that all have the same stance.
///  - stance: A string representing the stance of tricks stored in the tricks array.
///
struct TrickArray: Identifiable {
    let id = UUID()
    let tricks: [Trick]
    let stance: TrickStance
}

/// Contains functions for fetching a users trick list, storing the tricks, keeping track of the state of the fetch, and sorting the trick list by stance.
///
final class SelectTrickViewModel: ObservableObject {
    @Published var trickList: [Trick] = []
    @Published var fetchTrickListState: RequestState = .idle
    
    /// Fetches all the tricks from a user's trick list of the user has uploaded a trick item for that trick.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///
    @MainActor
    func fetchTricksWithTrickItems(userId: String) async {
        do {
            fetchTrickListState = .loading
            
            let tricks = try await TrickListManager.shared.fetchTricksWithTrickItems(
                userId: userId
            )
            self.trickList = tricks
            fetchTrickListState = .success
            
        } catch {
            fetchTrickListState = .failure(mapToSPError(error: error))
        }
    }
    
    func tricks(for stance: TrickStance) -> [Trick] {
        trickList.filter { $0.stance == stance }
    }
}
