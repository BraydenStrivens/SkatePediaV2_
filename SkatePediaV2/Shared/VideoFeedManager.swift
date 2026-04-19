//
//  VideoFeedManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/16/26.
//

import Foundation
import AVKit

class VideoFeedManager: ObservableObject {
    private var players: [Int : AVPlayer] = [:]
    private let maxPlayers = 5
    
    private var activeIndecies: Set<Int> = []
    
    func activate(index: Int, url: URL) {
        activeIndecies.insert(index)
        
        if players[index] == nil {
            players[index] = AVPlayer(url: url)
        }
        
        cleanup()
    }
    
    func deactivate(index: Int) {
        activeIndecies.remove(index)
        
        cleanup()
    }
    
    func player(for index: Int) -> AVPlayer? {
        players[index]
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
    
    private func expandedWindow() -> Set<Int> {
        var result = Set<Int>()
        
        for index in activeIndecies {
            result.formUnion((index - 2)...(index + 2))
        }
        
        return result
    }
    
    
    
    func player(for index: Int, url: URL) -> AVPlayer {
        if let existing = players[index] {
            return existing
        }
        
        let player = AVPlayer(url: url)
        players[index] = player
        
        cleanUpOutOfBoundsPlayersIfNeeded(currentIndex: index)
        
        return player
    }
    
    private func cleanUpOutOfBoundsPlayersIfNeeded(currentIndex: Int) {
        let validRange = (currentIndex - 2)...(currentIndex + 2)
        
        for key in players.keys {
            if !validRange.contains(key) {
                players[key]?.pause()
                players.removeValue(forKey: key)
            }
        }
    }
}
