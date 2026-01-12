//
//  ProVideosListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import SlidingTabView

struct ProVideosListView: View {
    @State var proSkater: ProSkater
    
    @StateObject var viewModel = ProVideosListViewModel()
    @State private var tabIndex: Int = 0
    private let tabs = ["Regular", "Fakie", "Switch", "Nollie"]
    
    var body: some View {
        LazyVStack {
            switch viewModel.fetchState {
            case .idle:
                VStack { }
                
            case .loading:
//                CustomProgressView(placement: .center)
                VStack {}
                
            case .success:
                if viewModel.videos.isEmpty {
                    HStack {
                        Spacer()
                        Text("No tricks available...")
                        Spacer()
                    }
                } else {
                    // Sorts the videos by stance if the pro has over 12 videos
                    if viewModel.videos.count < 12 {
                        unsortedTrickList
                    } else {
                        sortedTrickList
                    }
                }
            case .failure(let firestoreError):
                VStack {
                    Spacer()
                    Text(firestoreError.errorDescription ?? "Error...")
                    
                    Button {
                        Task {
                            await viewModel.fetchProVideos(proId: proSkater.id)
                        }
                    } label: {
                        Text("Try Again")
                    }
                    .foregroundColor(Color("buttonColor"))
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("buttonColor"))
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            if case .idle = viewModel.fetchState {
                Task {
                    await viewModel.fetchProVideos(proId: proSkater.id)
                }
            }
        }
    }
    
    var unsortedTrickList: some View {
        VStack {
            ForEach(viewModel.videos) { video in
                CustomNavLink(
                    destination: ProVideosView(videos: viewModel.videos, selectedVideo: video)
                        .customNavBarItems(title: "\(proSkater.name)'s Videos", subtitle: "", backButtonHidden: false)

                ) {
                    HStack {
                        Text(video.trickData.name)
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
            tabSelector

            let sortedVideos = viewModel.getSortedVideoList()
            
            switch(tabIndex) {
            case 0:
                videoListByStance(proVideosByStance: sortedVideos[0], allProVideos: viewModel.videos)
            case 1:
                videoListByStance(proVideosByStance: sortedVideos[1], allProVideos: viewModel.videos)
            case 2:
                videoListByStance(proVideosByStance: sortedVideos[2], allProVideos: viewModel.videos)
            case 3:
                videoListByStance(proVideosByStance: sortedVideos[3], allProVideos: viewModel.videos)
            default:
                Text("No Tricks")
            }
        }
    }
    
    @ViewBuilder
    var tabSelector: some View {
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
                                        .fill(isCurrentTab ? Color("buttonColor") : Color.clear)
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
    }
    
    @ViewBuilder
    func videoListByStance(proVideosByStance: [ProSkaterVideo], allProVideos: [ProSkaterVideo]) -> some View {
        VStack {
            if proVideosByStance.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("No tricks available...")
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ForEach(proVideosByStance) { proTrick in
                    CustomNavLink(
                        destination: ProVideosView(videos: allProVideos, selectedVideo: proTrick)
                            .customNavBarItems(title: "\(proSkater.name)'s Videos", subtitle: "", backButtonHidden: false)
                    ) {
                        HStack {
                            Text(proTrick.trickData.name)
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
    }
}
