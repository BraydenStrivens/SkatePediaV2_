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
                    // Separates the videos by stance into different views if the pro has over 12 videos
                    if viewModel.videos.count < 12 {
                        unseparatedTrickList
                    } else {
                        separatedTrickList
                    }
                }
            case .failure(let firestoreError):
                VStack {
                    Spacer()
                    Text(firestoreError.errorDescription ?? "Something went wrong...")
                    
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
    
    @ViewBuilder
    var unseparatedTrickList: some View {
        VStack(alignment: .leading) {
            let sortedVideos = viewModel.getSortedVideoList()
            
            ForEach(sortedVideos) { videosListByStance in
                
                if !videosListByStance.videos.isEmpty {
                    
                    Text(videosListByStance.stance)
                        .foregroundColor(.gray)
                        .font(.headline)
                    // Adds padding to each header except the top one
                        .padding([.top], videosListByStance.stance == Stance.Stances.regular.rawValue ? 0 : 5)
                    
                    ForEach(videosListByStance.videos) { video in
                        
                        CustomNavLink(
                            destination: ProVideosView(videos: viewModel.videos, selectedVideo: video)
                                .customNavBarItems(title: "\(proSkater.name)'s Videos", subtitle: "", backButtonHidden: false)
                        ) {
                            HStack {
                                Text(video.trickData.name)
                                    .offset(x: 20)

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
    
    var separatedTrickList: some View {
        VStack {
            stanceTabSelector

            let sortedVideos = viewModel.getSortedVideoList()
            
            switch(tabIndex) {
            case 0:
                videoListByStance(proVideosByStance: sortedVideos[0].videos, allProVideos: viewModel.videos)
            case 1:
                videoListByStance(proVideosByStance: sortedVideos[1].videos, allProVideos: viewModel.videos)
            case 2:
                videoListByStance(proVideosByStance: sortedVideos[2].videos, allProVideos: viewModel.videos)
            case 3:
                videoListByStance(proVideosByStance: sortedVideos[3].videos, allProVideos: viewModel.videos)
            default:
                Text("No Tricks")
            }
        }
    }
    
    var stanceTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                let index = tabs.firstIndex(of: tab)
                let isCurrentTab = index == tabIndex
                                    
                VStack {
                    Text(tab)
                        .font(.subheadline)
                        .fontWeight(isCurrentTab ? .semibold : .regular)
                        .frame(width: UIScreen.screenWidth * 0.2, height: 40)
                        .background {
                            Rectangle()
                                .fill(.gray.opacity(isCurrentTab ? 0.2 : 0.0))
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(isCurrentTab ? Color("buttonColor") : Color.clear)
                                        .frame(height: 1)
                                }
                        }
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
