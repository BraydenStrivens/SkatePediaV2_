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
    let stance: String
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
            
            let tricks = try await TrickListManager.shared.fetchTricksWithTrickItems(userId: userId)
            self.trickList.append(contentsOf: tricks)
    
            fetchTrickListState = .success
        } catch let error as FirestoreError {
            fetchTrickListState = .failure(.firestore(error))
            
        } catch {
            fetchTrickListState = .failure(.unknown)
        }
    }
    
    /// Sorts the fetched array of tricks by their stance.
    ///
    /// - Returns: An array containing four 'TrickArray' objects, each of which contain tricks for a specific stance.
    ///
    func sortTrickListByStance() -> [TrickArray] {
        var regular: [Trick] = []
        var fakie: [Trick] = []
        var _switch: [Trick] = []
        var nollie: [Trick] = []

        for trick in self.trickList {
            switch(trick.stance) {
            case Stance.Stances.regular.rawValue:
                regular.append(trick)
            case Stance.Stances.fakie.rawValue:
                fakie.append(trick)
            case Stance.Stances._switch.rawValue:
                _switch.append(trick)
            case Stance.Stances.nollie.rawValue:
                nollie.append(trick)
            default:
                print("ERROR: NO STANCE FOUND")
            }
        }
        return [
            TrickArray(tricks: regular, stance: Stance.Stances.regular.rawValue),
            TrickArray(tricks: fakie, stance: Stance.Stances.fakie.rawValue),
            TrickArray(tricks: _switch, stance: Stance.Stances._switch.rawValue),
            TrickArray(tricks: nollie, stance: Stance.Stances.nollie.rawValue)
        ]
    }
}
