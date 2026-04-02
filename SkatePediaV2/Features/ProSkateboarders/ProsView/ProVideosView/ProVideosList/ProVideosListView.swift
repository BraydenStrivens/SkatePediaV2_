//
//  ProVideosListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import SlidingTabView

struct ProVideosListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var proViewVM: ProViewModel
    
    @StateObject var viewModel = ProVideosListViewModel()
    @State private var selectedStance: TrickStance = .regular
    @State var transitionDirection: (insertion: Edge, removal: Edge) = (.trailing, .leading)
    
    var proSkater: ProSkater?
    
    var body: some View {
        if let proSkater = proSkater {
            VStack {
                switch viewModel.requestState {
                case .idle, .loading:
                    CustomProgressView(placement: .center)
                    
                case .success:
                    if viewModel.videos.isEmpty {
                        ContentUnavailableView(
                            "No Videos",
                            systemImage: "video.slash",
                            description: Text("Trick videos are currently unavailable for \(proSkater.name)")
                        )
                        
                    } else {
                        // Separates the videos by stance into different views if the pro has over 12 videos
                        if viewModel.videos.count < 12 {
                            unseparatedTrickList(proSkater)
                        } else {
                            separatedTrickList(proSkater)
                        }
                    }
                    
                case .failure(let spError):
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(spError.errorDescription ?? "Something went wrong...")
                    )
                }
            }
            .task {
                await viewModel.fetchProVideos(proId: proSkater.id)
            }
            
        } else {
            ContentUnavailableView(
                "Error Fetching Pros",
                systemImage: "exclamationmark.triangle"
            )
        }
    }
    
    func unseparatedTrickList(_ proSkater: ProSkater) -> some View {
        VStack(alignment: .leading) {
            ForEach(TrickStance.allCases) { stance in
                let filteredTricks = viewModel.proVideos(for: stance)

                if !filteredTricks.isEmpty {
                    Text(stance.camalCase)
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(.top)
                    
                    Divider()
                    
                    ForEach(filteredTricks) { video in
                        NavigationLink(
                            destination: ProVideosView(
                                videos: viewModel.videos,
                                selectedVideo: video
                            )
                            .customNavHeader(
                                title: "\(video.proData.name)",
                                showDivider: true
                            )
                        ) {
                            HStack {
                                Text(video.trickData.name)
                                    .padding(.leading)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(.vertical, 5)
                        }
                        
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        }
        .padding(.trailing)
    }
    
    func separatedTrickList(_ proSkater: ProSkater) -> some View {
        VStack {
            tabSelector
            
            videoListByStance(
                proSkater: proSkater,
                stance: selectedStance,
                allProVideos: viewModel.videos
            )
            .padding(.horizontal)
            .id(selectedStance)
            .transition(
                .asymmetric(
                    insertion: .move(edge: transitionDirection.insertion)
                        .combined(with: .scale(scale: 0.98)),
                    removal: .move(edge: transitionDirection.removal)
                )
            )
        }
    }
    
    var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(TrickStance.allCases) { stance in
                let isCurrentTab = selectedStance == stance
                
                Text(stance.camalCase)
                    .font(.body)
                    .fontWeight(isCurrentTab ? .semibold : .regular)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background {
                        Rectangle()
                            .fill(colorScheme == .dark
                                  ? (isCurrentTab ? Color(.systemGray5) : .clear)
                                  : (isCurrentTab ? Color(.systemBackground) : .clear)
                            )
                            .shadow(color: colorScheme == .dark
                                    ? .clear
                                    : .black.opacity(0.4), radius: 4, y: 3
                            )
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(isCurrentTab ? Color.accent : Color.clear)
                                    .frame(height: 2)
                            }
                    }
                    .onTapGesture {
                        selectStanceTab(newStance: stance)
                    }
            }
        }
    }
    
    @ViewBuilder
    func videoListByStance(
        proSkater: ProSkater,
        stance: TrickStance,
        allProVideos: [ProSkaterVideo]
    ) -> some View {
        let proVideosByStance = viewModel.proVideos(for: stance)
        
        VStack {
            if proVideosByStance.isEmpty {
                ContentUnavailableView(
                    "No \(stance.camalCase) Tricks",
                    systemImage: "skateboard"
                )

            } else {
                ForEach(proVideosByStance) { proVideo in
                    NavigationLink(
                        destination: ProVideosView(
                            videos: allProVideos,
                            selectedVideo: proVideo
                        )
                        .customNavHeader(
                            title: "\(proVideo.proData.name)",
                            showDivider: true
                        )
                    ) {
                        HStack {
                            Text(proVideo.trickData.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical, 5)
                    }
                    
                    Divider()
                }
            }
        }
    }
    
    func selectStanceTab(newStance: TrickStance) {
        guard newStance != selectedStance else { return }
        
        if newStance.index > selectedStance.index {
            transitionDirection = (.trailing, .leading)
        } else {
            transitionDirection = (.leading, .trailing)
        }
        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
            self.selectedStance = newStance
        }
    }
}
