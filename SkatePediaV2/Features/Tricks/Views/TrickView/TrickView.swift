//
//  TrickView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import SwiftUI

/// A detailed screen for viewing a specific trick, its user-generated trick items,
/// and associated professional reference videos.
///
/// This view acts as the main “analysis hub” for a single trick, allowing the user to:
/// - Review their recorded trick items
/// - Upload new trick items
/// - View “Learn First” prerequisites (if enabled in settings)
/// - Browse pro skater reference videos
///
/// Data is fetched via `TrickViewModel` and synchronized with shared stores
/// such as `TrickItemStore`.
///
/// - Parameters:
///   - userId: The ID of the current user.
///   - trick: The trick being displayed.
///   - viewModel: View model responsible for fetching trick items and pro videos.
struct TrickView: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: TrickListRouter
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var trickItemStore: TrickItemStore
    @EnvironmentObject private var prosStore: ProsStore
    
    // MARK: Parameters
    @StateObject var viewModel: TrickViewModel
    let userId: String
    let trick: Trick
    
    // MARK: Derived Properties
    private var trickItems: [TrickItem] {
        trickItemStore.trickItems(for: trick.id)
    }
    
    // MARK: Init
    init(
        userId: String,
        trick: Trick,
        viewModel: TrickViewModel
    ) {
        self.userId = userId
        self.trick = trick
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Group {
                    if userStore.trickSettings?.showLearnFirst == true {
                        learnFirstSection
                    }
                    
                    addTrickItemButton
                    
                    trickItemsSection
                }
                .padding(.horizontal, 10)
                
                proPreviewsSection
                
                Spacer()
            }
            .padding(.vertical, 10)
        }
        .customNavHeader(
            title: userStore.getTrickName(trick),
            showDivider: true
        )
        .task {
            await viewModel.fetchTrickItems(userId, for: trick.id)
            await viewModel.fetchProVideosForTrick(for: trick.id)
        }
    }
    
    // MARK: Subviews
    
    /// Displays the tricks that should be learned first if the user has it enabled in their `TrickSettings`
    private var learnFirstSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Learn First:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack {
                if userStore.trickSettings?.useTrickAbbreviations == true {
                    Text(trick.learnFirstAbbreviation)
                } else {
                    Text(trick.learnFirst)
                }
                Spacer()
            }
            .font(.headline)
            .fontWeight(.medium)
            .kerning(0.2)
            .padding()
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 10).protruded)
        }
    }
    
    private var addTrickItemButton: some View {
        Button {
            router.push(.addTrickItem(userId: userId, trick: trick))
            
        } label: {
            Text("Add Trick Item")
                .font(.body)
                .foregroundColor(.primary)
            Image(systemName: "plus.square")
                .foregroundColor(Color("buttonColor"))
                .frame(width: 20, height: 20)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    /// Displays the fetch state of the user's trick items for a trick. Displays a vertical list of the trick items if the
    /// fetch is successful.
    private var trickItemsSection: some View {
        VStack(alignment: .leading){
            Text("Trick Items:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            VStack(spacing: 10) {
                switch viewModel.trickItemFetchState {
                case .idle, .loading:
                    CustomProgressView(placement: .center)
                    
                case .success:
                    if trickItems.isEmpty {
                        NoTrickItemsCell(userId: userId, trick: trick)

                    } else {
                        ForEach(trickItems) { trickItem in
                            TrickItemCell(
                                userId: userId,
                                trickItem: trickItem,
                                trick: trick
                            )
                        }
                    }
                case .failure(let sPError):
                    SPContentUnavailableView(
                        title: "Error Fetching Trick Items",
                        description: sPError.errorDescription,
                        type: .blockingError
                    )
                }
            }
        }
    }
    
    /// Horizontally scrolling section of pro skater reference videos.
    ///
    /// Uses paging behavior and dynamically measures cell width to ensure
    /// full-screen-like horizontal swiping experience.
    private var proPreviewsSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Pro Videos:")
                Spacer()
                Text("\(prosStore.proVideos(forTrick: trick.id).count)")
            }
            .padding(.horizontal, 10)
            .font(.caption)
            .foregroundStyle(.gray)

            
            Group {
                switch viewModel.proVideosFetchState {
                case .idle, .loading:
                    CustomProgressView(placement: .center)

                case .success:
                    if prosStore.proVideos(forTrick: trick.id).isEmpty {
                        SPContentUnavailableView(
                            title: "No Pro Videos",
                            description: "Pro videos are currently unavailable for this trick."
                        )
                        
                    } else {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 0) {
                                ForEach(prosStore.proVideos(forTrick: trick.id)) { proVideo in
                                    ProTrickPreview(video: proVideo)
                                        .containerRelativeFrame(
                                            .horizontal,
                                            count: 1,
                                            span: 1,
                                            spacing: 0
                                        )
                                        .scrollTargetLayout()
                                }
                            }
                        }
                        .scrollTargetBehavior(.paging)
                    }
                case .failure(let sPError):
                    SPContentUnavailableView(
                        title: "Error Fetching Pro Videos",
                        description: sPError.errorDescription,
                        type: .blockingError
                    )
                }
            }
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).inset)
            .padding(.horizontal, 4)
        }
    }
}


