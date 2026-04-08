//
//  ProsVideoView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

/// A SwiftUI view displaying a list of pro skater videos in a vertically scrollable layout.
/// Highlights the initially selected video and supports paging and snapping behavior.
struct ProVideosView: View {
    let videos: [ProSkaterVideo]
    let selectedVideo: ProSkaterVideo
    
    @State private var selectedId: ProSkaterVideo.ID?
    
    /// Initializes the view with a list of videos and an initially selected video
    /// - Parameters:
    ///   - videos: The list of `ProSkaterVideo` to display
    ///   - selectedVideo: The video to initially focus on
    init(
        videos: [ProSkaterVideo],
        selectedVideo: ProSkaterVideo
    ) {
        self.videos = videos
        self.selectedVideo = selectedVideo
        _selectedId = State(initialValue: selectedVideo.id)
    }
    
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
                    .id(video.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $selectedId, anchor: .center)
        .customNavHeader(title: "\(selectedVideo.proData.name)")
    }
}
