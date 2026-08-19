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
    
    // MARK: Environment
    @EnvironmentObject private var errorStore: ErrorStore
    @EnvironmentObject private var trickItemStore: TrickItemStore
    @EnvironmentObject private var postStore: PostStore
    @EnvironmentObject private var tabRouter: TabRouter
    
    // MARK: State
    @StateObject private var router = TrickListRouter()
    @StateObject private var trickListSpinnerVM: TrickListSpinnerViewModel
    @StateObject private var trickSpinnerPresetsVM = TrickSpinnerPresetsViewModel()
    
    // MARK: Parameters
    let user: User
    let appEnv: AppEnvironment
    
    // MARK: Init
    init(
        user: User,
        appEnv: AppEnvironment
    ) {
        self.user = user
        self.appEnv = appEnv

        _trickListSpinnerVM = StateObject(
            wrappedValue: TrickListSpinnerViewModel(appEnv: appEnv)
        )
    }
    
    // MARK: Body
    var body: some View {
        NavigationStack(path: $router.path) {
            TrickListBuilder.build(
                user: user,
                appEnv: appEnv,
                errorStore: errorStore
            )
            .navigationDestination(for: TrickListRoute.self) { route in
                switch route {
                case .trickSpinner:
                    TrickListSpinnerBuilder.build(
                        appEnv: appEnv,
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
                        appEnv: appEnv
                    )
                    
                case .trickItem(let userId, let trick, let trickItem):
                    TrickItemBuilder.build(
                        userId: userId,
                        trick: trick,
                        trickItem: trickItem,
                        appEnv: appEnv,
                        errorStore: errorStore
                    )
                    
                case .addTrickItem(let userId, let trick):
                    AddTrickItemBuilder.build(
                        userId: userId,
                        trick: trick,
                        appEnv: appEnv,
                        errorStore: errorStore
                    )
                    
                case .compare(let trickData, let trickItem):
                    CompareBuilder.build(
                        errorStore: errorStore,
                        trickData: trickData,
                        trickItem: trickItem
                    )
                    
                case .postTrickItem(let user, let trick, let trickItem):
                    AddPostBuilder.build(
                        user: user,
                        trick: trick,
                        trickItem: trickItem,
                        postStore: postStore,
                        errorStore: errorStore,
                        onSuccess: {
                            trickItemStore.updateTrickItemPosted(
                                posted: true,
                                trickId: trick.id,
                                trickItemId: trickItem.id
                            )
                            router.pop()
                            tabRouter.navigate(to: .community)
                        }
                    )
                }
            }
        }
        .environmentObject(router)
    }
}
