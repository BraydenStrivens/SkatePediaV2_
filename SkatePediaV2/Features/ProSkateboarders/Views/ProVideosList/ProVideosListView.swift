//
//  ProVideosListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import SlidingTabView

/// A SwiftUI view that displays a list of pro skater videos.
/// Supports filtering by stance if the pro has many videos,
/// and allows navigation to a detailed video view via the router.
struct ProVideosListView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject private var router: ProsRouter
    @EnvironmentObject private var proViewVM: ProsViewModel
    
    @StateObject var viewModel = ProVideosListViewModel()
    
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
    
    /// Displays all videos without stance separation
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
                        Button {
                            router.push(.proVideos(viewModel.videos, video))
                        } label: {
                            proVideoListCell(video)
                        }
                        
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        }
        .padding(.trailing)
    }
    
    /// Single row cell for displaying a pro video in a list
    func proVideoListCell(_ proVideo: ProSkaterVideo) -> some View {
        HStack {
            Text(proVideo.trickData.name)
                .padding(.leading)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
    }
    
    /// Displays videos separated by stance with a tab selector
    func separatedTrickList(_ proSkater: ProSkater) -> some View {
        TrickStanceTabView { stance in
            videoListByStance(
                proSkater: proSkater,
                stance: stance,
                allProVideos: viewModel.videos
            )
        }
    }
    
    /// Returns a list of videos for a given stance
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
                    Button {
                        router.push(.proVideos(viewModel.videos, proVideo))
                    } label: {
                        proVideoListCell(proVideo)
                    }
                    
                    Divider()
                }
            }
        }
    }
}
