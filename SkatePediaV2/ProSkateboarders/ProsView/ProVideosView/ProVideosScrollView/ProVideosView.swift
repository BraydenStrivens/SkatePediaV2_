//
//  ProsVideoView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

struct ProVideosView: View {
    let videos: [ProSkaterVideo]
    let selectedVideo: ProSkaterVideo
        
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                LazyVStack(spacing: 10) {
                    ForEach(videos) { video in
                        ProVideoCell(video: video)
                            .frame(height: UIScreen.screenHeight * 0.8)
                            .id(video.id)
                        
                        Divider()
                    }
                }
                .onFirstAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollViewProxy.scrollTo(selectedVideo.id, anchor: .bottom)
                    }
                }
                
            }
        }
    }
}
