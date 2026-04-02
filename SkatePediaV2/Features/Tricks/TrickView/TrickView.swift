//
//  TrickView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import SwiftUI

struct TrickView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var trickListStore: TrickListStore
    @EnvironmentObject var trickItemStore: TrickItemStore
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: TrickViewModel
    
    @State private var cellWidth: CGFloat = 0
    
    let userId: String
    let trick: Trick
    
    var trickItems: [TrickItem] {
        trickItemStore.trickItems(for: trick.id)
    }
    
    init(
        userId: String,
        trick: Trick,
        viewModel: TrickViewModel
    ) {
        self.userId = userId
        self.trick = trick
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                if userStore.trickSettings?.showLearnFirst == true {
                    learnFirstSection
                }
                
                addTrickItemButton
                
                trickItemsSection
                
                proPreviewsSection
                
                Spacer()
            }
            .padding(10)
        }
        .customNavHeader(
            title: trick.displayName(useAbbreviation: userStore.trickSettings?.useTrickAbbreviations == true),
            showDivider: true
        )
        .task {
            await viewModel.fetchTrickItems(userId, for: trick.id)
            await viewModel.fetchProVideosForTrick(for: trick.id)
        }
    }
    
    var learnFirstSection: some View {
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
    
    var addTrickItemButton: some View {
        NavigationLink(
            destination: AddTrickItemViewContainer(
                userId: userId,
                trick: trick
            )
        ) {
            Text("Add Trick Item")
                .font(.body)
                .foregroundColor(.primary)
            Image(systemName: "plus.square")
                .foregroundColor(Color("buttonColor"))
                .frame(width: 20, height: 20)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    var trickItemsSection: some View {
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
                        ContentUnavailableView {
                            VStack {
                                Text("No Trick Items")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Upload a trick item and start analyzing your skateboarding!")
                                    .font(.callout)
                                    .foregroundStyle(.gray)
                            }
                        }
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
                    ContentUnavailableView(
                        "Error Fetching Trick Items",
                        systemImage: "exclamationmark.triangle",
                        description: Text(sPError.errorDescription ?? "Something went wrong...")
                    )
                }
            }
            .padding()
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).inset)
        }
    }
    
    var proPreviewsSection: some View {
        VStack(alignment: .leading) {
            Text("Pro Videos:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            Group {
                switch viewModel.proVideosFetchState {
                case .idle, .loading:
                    CustomProgressView(placement: .center)

                case .success:
                    if viewModel.proVideos.isEmpty {
                        ContentUnavailableView(
                            "No Pro Videos",
                            systemImage: "",
                            description: Text("Pro videos are currently unavailable for this trick.")
                        )
                        
                    } else {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 0) {
                                ForEach(viewModel.proVideos) { proVideo in
                                    ProTrickPreview(video: proVideo)
                                    .frame(width: cellWidth)
                                    .scrollTargetLayout()
                                }
                            }
                        }
                        .scrollTargetBehavior(.paging)
                    }
                case .failure(let spError):
                    ContentUnavailableView(
                        "Error Fetching Trick Items",
                        systemImage: "exclamationmark.triangle",
                        description: Text(spError.errorDescription ?? "Something went wrong...")
                    )
                }
            }
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).inset)
        }
        .background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: WidthPreferenceKey.self, value: proxy.size.width)
                    .onPreferenceChange(WidthPreferenceKey.self) { width in
                        guard width > 0 else { return }
                        cellWidth = width
                    }
            }
        }
    }
}


