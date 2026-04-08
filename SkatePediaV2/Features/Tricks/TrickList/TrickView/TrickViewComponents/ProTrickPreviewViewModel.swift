//
//  ProTrickPreviewViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/5/26.
//

import Foundation
import AVKit

final class ProTrickPreviewViewModel: ObservableObject {
    let player: AVPlayer
    private let item: AVPlayerItem
    @Published var isLooping: Bool = false
    
    init(proVideo: ProSkaterVideo) {
        self.item = AVPlayerItem(url: URL(string: proVideo.videoData.videoUrl)!)
        self.player = AVPlayer(url: URL(string: proVideo.videoData.videoUrl)!)
        
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
