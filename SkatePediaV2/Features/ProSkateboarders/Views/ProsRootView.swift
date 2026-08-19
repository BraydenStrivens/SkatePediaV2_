//
//  ProSkateboardersRootView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/4/26.
//

import SwiftUI

/// The root view for the Pro Skaters section.
///
/// Manages navigation between the main pros list, individual pro videos,
/// and the compare view using a `NavigationStack` and a `ProsRouter`.
struct ProsRootView: View {
    
    // MARK: Envrionment
    @EnvironmentObject private var errorStore: ErrorStore
    @EnvironmentObject private var appEnv: AppEnvironment
    
    // MARK: State
    @StateObject private var router: ProsRouter = ProsRouter()
    
    // MARK: Body
    var body: some View {
        NavigationStack(path: $router.path) {
            ProBuilder.build(appEnv: appEnv)
                .navigationDestination(for: ProsRoute.self) { route in
                    switch route {
                    case .proVideos(let proId, let selectedVideo):
                        ProVideosView(
                            proId: proId,
                            selectedVideo: selectedVideo
                        )
                        
                    case .compare(let trickData, let proVideo):
                        CompareBuilder.build(
                            errorStore: errorStore,
                            trickData: trickData,
                            proVideo: proVideo
                        )
                    }
                }
        }
        .environmentObject(router)
    }
}
