//
//  SelectCompareVideoSheet.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/7/26.
//

import SwiftUI

struct SelectCompareVideoSheet: View {
//    @EnvironmentObject private var compareViewModel: CompareViewModel

    let trickId: String
    let initialSelection: CompareVideo?
    let onContinue: (CompareVideo) -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = SelectCompareVideoSheetViewModel()
    @State private var tabIndex: Int = 0
    
    @State private var selectedVideo: CompareVideo?
    
    init(trickId: String,
         initialSelection: CompareVideo?,
         onContinue: @escaping (CompareVideo) -> Void,
         onCancel: @escaping () -> Void
    ) {
        self.trickId = trickId
        self.initialSelection = initialSelection
        self.onContinue = onContinue
        self.onCancel = onCancel
        _selectedVideo = State(initialValue: initialSelection)
    }
    
    var body: some View {
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
                Text(firestoreError.errorDescription ?? "ERROR...")
            }
            
        }
        .navigationTitle(tabIndex == 0 ? "Select Trick Item" : "Select Pro Video")
        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button {
//                    dismiss()
//                } label: {
//                    Text("Cancel")
//                        .foregroundColor(.primary)
//                }
//            }
//            ToolbarItem(placement: .topBarTrailing) {
//                Button {
//                    dismiss()
//                } label: {
//                    Text("Continue")
////                        .foregroundColor(.primary.opacity(dummySelectedTrickItem == nil ? 0.4 : 1))
//                }
////                .disabled(dummySelectedTrickItem == nil)
//            }
//        }
    }
    
    @ViewBuilder
    var tabSelector: some View {
        HStack {
            Button("Cancel") {
                onCancel()
            }
            
            HStack(spacing: 0) {
                Text("Trick Items")
                    .fontWeight(tabIndex == 0 ? .medium : .regular)
                    .frame(width: 120, height: 40)
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
                    .frame(width: 120, height: 40)
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
            
            Button {
                if let selectedVideo { onContinue(selectedVideo) }
                
            } label: {
                Text("Continue")
                    .foregroundColor(selectedVideo == nil ? .gray : Color("buttonColor"))
            }
            .disabled(selectedVideo == nil)
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
