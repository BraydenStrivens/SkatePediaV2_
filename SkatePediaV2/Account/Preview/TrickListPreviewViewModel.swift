//
//  TrickListPreviewViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/10/25.
//

import Foundation
import SwiftUI

final class TrickListPreviewViewModel: ObservableObject {
    
    @Published private(set) var trickList: [Trick] = []
    @Published var threeStarTricks: [Trick] = []
    @Published var twoStarTricks: [Trick] = []
    @Published var oneStarTricks: [Trick] = []
    @Published var zeroStarTricks: [Trick] = []
    @Published var unstartedStarTricks: [Trick] = []
    
    @MainActor
    func fetchTrickList(userId: String, stance: String) async throws {
        do {
            self.trickList = try await TrickListManager.shared.fetchTricksByStance(userId: userId, stance: stance)
            sortTricks()
        } catch {
            print("DEBUG: Failed to fetch user trick list by stance: \(error)")
        }
    }
    
    @MainActor
    func sortTricks() {
        for trick in trickList {
            let progressArray = trick.progress
            
            if progressArray.isEmpty {
                unstartedStarTricks.append(trick)
            } else if progressArray.max() == 0 {
                zeroStarTricks.append(trick)
            } else if progressArray.max() == 1 {
                oneStarTricks.append(trick)
            } else if progressArray.max() == 2 {
                twoStarTricks.append(trick)
            } else {
                threeStarTricks.append(trick)
            }
        }
    }
}
