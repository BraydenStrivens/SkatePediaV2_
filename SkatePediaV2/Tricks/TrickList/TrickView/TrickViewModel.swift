//
//  TrickViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import Foundation
import Combine
import FirebaseAuth

final class TrickViewModel: ObservableObject {
    @Published var trickItems: [TrickItem] = []
    @Published var proVideos: [ProSkaterVideo] = []

    @Published var trickItemFetchState: RequestState = .idle
    @Published var proVideosFetchState: RequestState = .idle
    @Published var deleteTrickItemState: RequestState = .idle
    
    @MainActor
    func fetchTrickItems(trickId: String) async {
        do {
            self.trickItemFetchState = .loading
            
            guard let currentUid = Auth.auth().currentUser?.uid else { throw FirestoreError.unknown }
            
            let items = try await TrickItemManager.shared.getTrickItems(userId: currentUid, trickId: trickId)
            self.trickItems.append(contentsOf: items)

            self.trickItemFetchState = .success
            
        } catch let error as FirestoreError {
            self.trickItemFetchState = .failure(.firestore(error))
            
        } catch {
            self.proVideosFetchState = .failure(.unknown)
        }
    }
    
    @MainActor
    func fetchProVideosForTrick(trickId: String) async {
        do {
            self.proVideosFetchState = .loading
            
            let fetchedVideos = try await ProManager.shared.getProVideosByTrick(trickId: trickId)
            self.proVideos.append(contentsOf: fetchedVideos)
                                    
            self.proVideosFetchState = .success
            
        } catch let error as FirestoreError {
            self.proVideosFetchState = .failure(.firestore(error))
            
        } catch {
            self.proVideosFetchState = .failure(.unknown)
        }
    }
}
