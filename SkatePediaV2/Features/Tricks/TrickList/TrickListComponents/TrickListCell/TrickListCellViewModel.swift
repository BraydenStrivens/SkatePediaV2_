//
//  TrickListCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation

@MainActor
final class TrickListCellViewModel: ObservableObject {
    private let useCases: TrickListUseCases
    private let errorStore: ErrorStore
    
    init(
        useCases: TrickListUseCases,
        errorStore: ErrorStore
    ) {
        self.useCases = useCases
        self.errorStore = errorStore
    }
    
    func hideTrick(userId: String, trick: Trick) async {
        var updatedTrick = trick
        updatedTrick.hidden = true
        
        let request = UpdateTrickRequest(
            userId: userId,
            updatedTrick: updatedTrick
        )
        
        do {
            try await useCases.update(request)
        } catch {
            errorStore.present(error, title: "Error Hiding Trick")
        }
    }
    
    func deleteTrick(_ toDelete: Trick) async {
        do {
            try await useCases.delete(toDelete)
        } catch {
            errorStore.present(error, title: "Error Deleting Trick")
        }
    }
}
