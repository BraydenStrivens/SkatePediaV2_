//
//  ProsVideoView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

/// A vertically scrollable SwiftUI view displaying a collection of
/// professional skater videos.
///
/// `ProVideosView` presents a paged, full-screen style browsing experience
/// using a `ScrollView` and `LazyVStack`. Each item is rendered using
/// ``ProVideoCell``.
///
/// The view automatically scrolls to and highlights the initially selected
/// video when presented.
struct ProVideosView: View {
    
    // MARK: Environment
    @EnvironmentObject private var prosStore: ProsStore
    
    // MARK: Parameters
    private let proId: String
    private let selectedVideo: ProSkaterVideo
    
    // MARK: Derived/Private Properties
    @State private var selectedId: ProSkaterVideo.ID?
    private var videos: [ProSkaterVideo] {
        prosStore.proVideos(forPro: proId)
    }
        
    // MARK: Init
    init(
        proId: String,
        selectedVideo: ProSkaterVideo
    ) {
        self.proId = proId
        self.selectedVideo = selectedVideo
        _selectedId = State(initialValue: selectedVideo.id)
    }
    
    // MARK: Body
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
