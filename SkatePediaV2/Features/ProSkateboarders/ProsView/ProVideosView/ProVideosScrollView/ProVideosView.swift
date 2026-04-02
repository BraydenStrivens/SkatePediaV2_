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
    
    @State private var selectedId: ProSkaterVideo.ID?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(videos) { video in
                    ProVideoCell(
                        video: video
                    )
                    .containerRelativeFrame(
                        .vertical,
                        count: 1,
                        span: 1,
                        spacing: 0
                    )
                    .scrollTargetLayout()
                    .id(video.id)
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $selectedId, anchor: .center)
        .onAppear { selectedId = selectedVideo.id }
    }
}
