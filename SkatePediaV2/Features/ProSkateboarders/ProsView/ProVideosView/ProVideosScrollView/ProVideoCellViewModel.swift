//
//  ProVideoCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/11/25.
//

import Foundation
import AVKit


final class ProVideoCellViewModel: ObservableObject {    
    let player: AVPlayer
    private let item: AVPlayerItem
    @Published var isLooping: Bool = false
    
    init(videoUrl: String) {
        self.item = AVPlayerItem(url: URL(string: videoUrl)!)
        self.player = AVPlayer(url: URL(string: videoUrl)!)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )
    }
    
    @objc private func didFinish() {
        guard isLooping else { return }
        player.seek(to: .zero)
        player.play()
    }
    
    func stopOnDisappear() {
        player.pause()
        player.seek(to: .zero)
        self.isLooping = false
    }
    
    deinit {
        player.pause()
        player.replaceCurrentItem(with: nil)
        NotificationCenter.default.removeObserver(self)
    }
}
