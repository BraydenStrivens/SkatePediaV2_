//
//  SelectCompareVideoSheet.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/7/26.
//

import SwiftUI

struct SelectCompareVideoSheet: View {
    let trickId: String
    let initialSelection: CompareVideo?
    let defaultTabIndex: Int
    let onContinue: (CompareVideo) -> Void
    let onCancel: () -> Void
    
    @StateObject var viewModel = SelectCompareVideoSheetViewModel()
    @State private var tabIndex: Int = 0
    @State private var selectedVideo: CompareVideo?
    
    init(
        trickId: String,
        initialSelection: CompareVideo?,
        defaultTabIndex: Int,
        onContinue: @escaping (CompareVideo) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.trickId = trickId
        self.initialSelection = initialSelection
        self.defaultTabIndex = defaultTabIndex
        self.onContinue = onContinue
        self.onCancel = onCancel
        _selectedVideo = State(initialValue: initialSelection)
        _tabIndex = State(initialValue: defaultTabIndex)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.currentUserFetchState {
                case .idle:
                    VStack { }
                    
                case .loading:
                    CustomProgressView(placement: .center)
                    
                case .success:
                    VStack {
                        ScrollView {
                            tabSelector
                            
                            switch tabIndex {
                            case 0:
                                trickItemSelectionView
                                    .onAppear {
                                        if case .idle = viewModel.trickItemsFetchState {
                                            Task {
                                                await viewModel.fetchTrickItemsForTrick(trickId: trickId)
                                            }
                                        }
                                    }
                            case 1:
                                proVideoSelectionView
                                    .onAppear {
                                        if case .idle = viewModel.proVideosFetchState {
                                            Task {
                                                await viewModel.fetchProVideosForTrick(trickId: trickId)
                                            }
                                        }
                                    }
                            default:
                                VStack {
                                    Text("Error...")
                                }
                            }
                        }
                    }
                    .padding()
                    
                case .failure(let firestoreError):
                    Text("Error fetching user")
                    Text(firestoreError.errorDescription ?? "Something went wrong...")
                }
                
            }
            .navigationTitle("Select Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let selectedVideo {
                            onContinue(selectedVideo)
                        }
                    } label: {
                        Text("Continue")
                            .foregroundColor(selectedVideo == nil ? .gray : Color("AccentColor"))
                    }
                    .disabled(selectedVideo == nil)
                }
            }
        }
    }
    
    @ViewBuilder
    var tabSelector: some View {
        HStack {
            HStack(spacing: 0) {
                Text("Trick Items")
                    .fontWeight(tabIndex == 0 ? .medium : .regular)
                    .frame(width: 150, height: 50)
                    .background {
                        if tabIndex == 0 {
                            Rectangle()
                                .fill(.shadow(.inner(color: .primary, radius: 3, x: 1, y: 1)))
                                .foregroundColor(Color(uiColor:  UIColor.systemBackground))
                        }
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            tabIndex = 0
                        }
                    }
                
                Text("Pro Videos")
                    .fontWeight(tabIndex == 1 ? .medium : .regular)
                    .frame(width: 150, height: 50)
                    .background {
                        if tabIndex == 1 {
                            Rectangle()
                                .fill(.shadow(.inner(color: .primary, radius: 3, x: 1, y: 1)))
                                .foregroundColor(Color(uiColor:  UIColor.systemBackground))
                        }
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            tabIndex = 1
                        }
                    }
            }
            .background {
                Rectangle()
                    .stroke(.primary, lineWidth: 1)
            }
        }
    }
    
    @ViewBuilder
    var trickItemSelectionView: some View {
        switch viewModel.trickItemsFetchState {
        case .idle:
            VStack { }
            
        case .loading:
            CustomProgressView(placement: .center)
            
        case .success:
            VStack { }
            if viewModel.trickItems.isEmpty {
                HStack {
                    Spacer()
                    Text("No trick items uploaded for trick")
                    Spacer()
                }
            } else {
                ForEach(viewModel.trickItems) { trickItem in
                    SelectTrickItemCell(user: viewModel.currentUser, trickItem: trickItem, currentSelection: $selectedVideo)
                }
            }
        case .failure(let error):
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(error.errorDescription ?? "Error...")
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var proVideoSelectionView: some View {
        switch viewModel.proVideosFetchState {
        case .idle:
            VStack { }
            
        case .loading:
            CustomProgressView(placement: .center)
            
        case .success:
            VStack { }
            if viewModel.proVideos.isEmpty {
                HStack {
                    Spacer()
                    Text("No trick items uploaded for trick")
                    Spacer()
                }
            } else {
                ForEach(viewModel.proVideos) { proVideo in
                    SelectProVideoCell(video: proVideo, currentSelection: $selectedVideo)
                }
                
            }
        case .failure(let error):
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(error.errorDescription ?? "Error...")
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
