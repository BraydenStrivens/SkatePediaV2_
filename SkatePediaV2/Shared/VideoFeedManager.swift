//
//  VideoFeedManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/16/26.
//

import Foundation
import AVKit

class VideoFeedManager<ID: Hashable>: ObservableObject {
    private var players: [ID : AVPlayer] = [:]
    private var activeIDs: Set<ID> = []
    
    private var orderedIDs: [ID] = []
    
    func setOrder(_ ids: [ID]) {
        self.orderedIDs = ids
    }
    
    func appendIDs(_ newIds: [ID]) {
        for id in newIds where !orderedIDs.contains(id) {
            orderedIDs.append(id)
        }
        
        cleanup()
    }
    
    func activate(id: ID, url: URL) {
        activeIDs.insert(id)
        
        if players[id] == nil {
            players[id] = AVPlayer(url: url)
        }
        
        cleanup()
    }
    
    func deactivate(id: ID) {
        activeIDs.remove(id)
        cleanup()
    }
    
    func player(for id: ID) -> AVPlayer? {
        players[id]
    }
    
    private func cleanup() {
        let allowed = expandedWindow()
        
        for key in players.keys {
            if !allowed.contains(key) {
                players[key]?.pause()
                players.removeValue(forKey: key)
            }
        }
    }
    
    private func expandedWindow() -> Set<ID> {
        var result = Set<ID>()
        
        for activeID in activeIDs {
            guard let index = orderedIDs.firstIndex(of: activeID) else { continue }
            
            let lower = max(0, index - 2)
            let upper = min(orderedIDs.count - 1, index + 2)
            
            for i in lower...upper {
                result.insert(orderedIDs[i])
            }
        }
        
        return result
    }
}

//class VideoFeedManager: ObservableObject {
//    private var players: [Int : AVPlayer] = [:]
//    private let maxPlayers = 5
//
//    private var activeIndecies: Set<Int> = []
//
//    func activate(index: Int, url: URL) {
//        activeIndecies.insert(index)
//
//        if players[index] == nil {
//            players[index] = AVPlayer(url: url)
//        }
//
//        cleanup()
//    }
//
//    func deactivate(index: Int) {
//        activeIndecies.remove(index)
//
//        cleanup()
//    }
//
//    func player(for index: Int) -> AVPlayer? {
//        players[index]
//    }
//
//    private func cleanup() {
//        let allowed = expandedWindow()
//
//        for key in players.keys {
//            if !allowed.contains(key) {
//                players[key]?.pause()
//                players.removeValue(forKey: key)
//            }
//        }
//    }
//
//    private func expandedWindow() -> Set<Int> {
//        var result = Set<Int>()
//
//        for index in activeIndecies {
//            result.formUnion((index - 2)...(index + 2))
//        }
//
//        return result
//    }
//
//
//
//    func player(for index: Int, url: URL) -> AVPlayer {
//        if let existing = players[index] {
//            return existing
//        }
//
//        let player = AVPlayer(url: url)
//        players[index] = player
//
//        cleanUpOutOfBoundsPlayersIfNeeded(currentIndex: index)
//
//        return player
//    }
//
//    private func cleanUpOutOfBoundsPlayersIfNeeded(currentIndex: Int) {
//        let validRange = (currentIndex - 2)...(currentIndex + 2)
//
//        for key in players.keys {
//            if !validRange.contains(key) {
//                players[key]?.pause()
//                players.removeValue(forKey: key)
//            }
//        }
//    }
//}
