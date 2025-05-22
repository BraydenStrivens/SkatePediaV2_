//
//  ProVideosListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import SlidingTabView

struct ProVideosListView: View {
    @StateObject var viewModel = ProVideosViewModel()
    @State var proSkater: ProSkater
    @State private var tabIndex: Int = 0
    private let tabs = ["Regular", "Fakie", "Switch", "Nollie"]
    
    var body: some View {
        LazyVStack {
            if viewModel.videos.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("NO DATA FETCHED")
                }
                
            } else {
                if viewModel.videos.count < 12 {
                    unsortedTrickList
                } else {
                    sortedTrickList
                }
                
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal)
        .onFirstAppear {
            if viewModel.videos.isEmpty {
                viewModel.fetchProVideos(proId: proSkater.id)
            }
        }
    }
    
    var unsortedTrickList: some View {
        VStack {
            ForEach(viewModel.videos) { video in
                CustomNavLink(destination: ProVideosView(videos: viewModel.videos, selectedVideo: video)) {
                    HStack {
                        Text(video.trickName)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(.vertical, 5)
                }
                .foregroundColor(.primary)
                
                Divider()
                
            }
        }
    }
    
    var sortedTrickList: some View {
        VStack {
            HStack {
                ForEach(tabs, id: \.self) { tab in
                    let index = tabs.firstIndex(of: tab)
                    let isCurrentTab = index == tabIndex
                                        
                    VStack {
                        Text(tab)
                            .font(.subheadline)
                            .fontWeight(isCurrentTab ? .semibold : .regular)
                            .padding(8)
                            .background {
                                Rectangle()
                                    .fill(.gray.opacity(isCurrentTab ? 0.2 : 0.0))
                                    .overlay(alignment: .bottom) {
                                        Rectangle()
                                            .fill(isCurrentTab ? Color.blue : Color.clear)
                                            .frame(height: 1)
                                    }
                            }
                            .padding(8)
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if let index = index { self.tabIndex = index }
                        }
                    }
                }
            }

            let sortedTricks = viewModel.getSortedVideoList()
            
            switch(tabIndex) {
            case 0:
                ProTricksListView(trickList: sortedTricks[0], allTricks: viewModel.videos)
            case 1:
                ProTricksListView(trickList: sortedTricks[1], allTricks: viewModel.videos)
            case 2:
                ProTricksListView(trickList: sortedTricks[2], allTricks: viewModel.videos)
            case 3:
                ProTricksListView(trickList: sortedTricks[3], allTricks: viewModel.videos)
            default:
                Text("No Tricks")
            }
        }
    }
}
