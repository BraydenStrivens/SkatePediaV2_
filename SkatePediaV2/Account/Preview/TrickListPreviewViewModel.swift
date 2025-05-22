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
    @Published var threeStarTricks: [Trick] = []
    @Published var twoStarTricks: [Trick] = []
    @Published var oneStarTricks: [Trick] = []
    @Published var zeroStarTricks: [Trick] = []
    @Published var unstartedStarTricks: [Trick] = []
    
    ///
    /// Fetches a user's trick list by stance and sorts it by the progress on each trick.
    ///
    @MainActor
    func fetchTrickList(userId: String, stance: String) async throws {
        do {
            self.trickList = try await TrickListManager.shared.fetchTricksByStance(userId: userId, stance: stance)
            sortTricks()
        } catch {
            print("DEBUG: Failed to fetch user trick list by stance: \(error)")
        }
    }
    
    ///
    /// Splits the fetched trick list array in to four arrays based on the user's progress on each trick.
    /// 
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
