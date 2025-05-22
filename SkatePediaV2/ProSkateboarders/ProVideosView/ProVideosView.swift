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
                            .id(video.id)
                        
                        Divider()
                    }
                }
                .onFirstAppear {
                    scrollViewProxy.scrollTo(selectedVideo.id, anchor: .bottom)
                }
                
            }
        }
        .customNavBarItems(title: "Pro Videos", subtitle: "", backButtonHidden: false)
    }
}

//#Preview {
//    ProsVideoView()
//}
