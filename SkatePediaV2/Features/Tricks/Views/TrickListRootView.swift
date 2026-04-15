//
//  TrickListRootView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/7/26.
//

import SwiftUI

/// Root view for the Trick List feature.
///
/// Responsible for initializing required view models, injecting dependencies,
/// and handling navigation between all trick-related screens using a `NavigationStack`.
///
/// This view acts as the entry point for the trick list flow, coordinating routing
/// and passing shared state throughout the feature.
///
/// - Parameters:
///   - user: The current authenticated user.
///   - trickListStore: Store managing trick list data and state.
struct TrickListRootView: View {
    @EnvironmentObject private var errorStore: ErrorStore
    @EnvironmentObject private var trickItemStore: TrickItemStore
    @EnvironmentObject private var postStore: PostStore
    
    @StateObject private var router = TrickListRouter()
    @StateObject private var trickListSpinnerVM: TrickListSpinnerViewModel
    @StateObject private var trickSpinnerPresetsVM = TrickSpinnerPresetsViewModel()
    
    let user: User
    let trickListStore: TrickListStore
    
    init(
        user: User,
        trickListStore: TrickListStore
    ) {
        self.user = user
        self.trickListStore = trickListStore
        
        _trickListSpinnerVM = StateObject(
            wrappedValue: TrickListSpinnerViewModel(trickListStore: trickListStore)
        )
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            TrickListBuilder.build(
                user: user,
                errorStore: errorStore,
                trickListStore: trickListStore
            )
            .navigationDestination(for: TrickListRoute.self) { route in
                switch route {
                case .trickSpinner:
                    TrickListSpinnerBuilder.build(
                        trickListStore: trickListStore,
                        trickSpinnerPresetsVM: trickSpinnerPresetsVM
                    )
                    
                case .createTrickSpinnerPreset(let initialPreset, let presetCount):
                    CreateSpinnerPresetView(
                        initialPreset: initialPreset,
                        presetCount: presetCount,
                        trickSpinnerPresetsVM: trickSpinnerPresetsVM
                    )
                    
                case .trick(let userId, let trick):
                    TrickBuilder.build(
                        userId: userId,
                        trick: trick,
                        trickItemStore: trickItemStore
                    )
                    
                case .trickItem(let userId, let trick, let trickItem):
                    TrickItemBuilder.build(
                        userId: userId,
                        trick: trick,
                        trickItem: trickItem,
                        errorStore: errorStore,
                        trickItemStore: trickItemStore,
                        postStore: postStore,
                        trickListStore: trickListStore
                    )
                    
                case .addTrickItem(let userId, let trick):
                    AddTrickItemBuilder.build(
                        userId: userId,
                        trick: trick,
                        trickItemStore: trickItemStore
                    )
                    
                case .compare(let trickData, let trickItem):
                    CompareBuilder.build(
                        errorStore: errorStore,
                        trickData: trickData,
                        trickItem: trickItem
                    )
                }
            }
        }
        .environmentObject(router)
    }
}
