//
//  SelectTrickItemViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/15/26.
//

import Foundation

/// Contains a function for fetching the trick items for the selected trick, variables storing the fetched trick items, the selected trick item,
/// and the state of the trick item fetch.  Used as a StateObject in the 'SelectTrickItemView'.
///
final class SelectTrickItemViewModel: ObservableObject {
    @Published var trickItems: [TrickItem] = []
    @Published var selectedTrickItem: TrickItem? = nil
    @Published var trickItemFetchState: RequestState = .idle
    
    /// Attempts to fetch all the trick items belonging to the inputted user for the inputted trick id. Keeps track of the state of this fetch
    /// and updates the view accordingly.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - trickId: The id of the select trick for which the trick items are fetched with.
    ///
    @MainActor
    func fetchTrickItemsForTrick(userId: String, trickId: String) async {
        do {
            trickItemFetchState = .loading
            
            let trickItems = try await TrickItemManager.shared.getTrickItems(userId: userId, trickId: trickId)
            self.trickItems.append(contentsOf: trickItems)
            
            trickItemFetchState = .success
            
        } catch let error as FirestoreError {
            trickItemFetchState = .failure(.firestore(error))
            
        } catch {
            trickItemFetchState = .failure(.unknown)
        }
    }
}
