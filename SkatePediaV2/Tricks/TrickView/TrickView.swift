//
//  TrickView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import SwiftUI

struct TrickView: View {
    @StateObject var viewModel = TrickViewModel()
    
    let userId: String
    let trick: Trick
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
                learnFirstSection
                
                addTrickItemSection
                
                trickItemsSection
                
                proPreviewsSection
                
                Spacer()
            }
            .padding()
        }
        .customNavBarItems(title: trick.name, subtitle: "", backButtonHidden: false)
        .onFirstAppear {
            Task {
                if !viewModel.fetchedTrickItems {
                    try await viewModel.fetchTrickItems(trickId: trick.id)
                }
                if !viewModel.fetchedProVideos {
                    try await viewModel.fetchProVideosForTrick(trickId: trick.id)
                }
            }
        }

    }
    
    var learnFirstSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Learn First:")
                .font(.footnote)
                .foregroundColor(.gray)
            Text(trick.learnFirst)
                .font(.headline)
            HStack {
                Spacer()
            }
        }
        .padding()
        .background(Color(uiColor: UIColor.systemBackground))
        .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 2)
    }
    
    var addTrickItemSection: some View {
        HStack(alignment: .center) {
            Spacer()
            
            CustomNavLink(
                destination: AddTrickItemView(userId: userId, trick: trick, trickItems: $viewModel.trickItems)
                    .customNavBarItems(title: "Add Trick Item", subtitle: "\(trick.name)", backButtonHidden: false)
            ) {
                Text("Add Trick Item")
                    .font(.body)
                    .foregroundColor(.primary)
                Image(systemName: "plus.square")
                    .foregroundColor(.blue)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal)
    }
    
    var trickItemsSection: some View {
        Section(header: Text("Trick Items:").foregroundColor(.gray)) {
            VStack {
                if viewModel.fetchingTrickItems {
                    CustomProgressView(placement: .center)
                } else {
                    if viewModel.trickItems.isEmpty {
                        VStack(alignment: .center) {
                            HStack { Spacer() }
                            Spacer()
                            Text("No Trick Items")
                                .font(.title3)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        ForEach(viewModel.trickItems) { trickItem in
                            TrickItemCell(userId: userId, trickItem: trickItem, trickItems: $viewModel.trickItems)
                        }
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray.opacity(0.06))
            }
        }
    }
    
    var proPreviewsSection: some View {
        Section(header: Text("Pro Videos:").foregroundColor(.gray)) {
            if viewModel.fetchingProVideos {
                CustomProgressView(placement: .center)
                
            } else {
                if viewModel.proVideos.isEmpty {
                    HStack {
                        Spacer()
                        Text("Pro videos are currently unavailable for this trick...")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray.opacity(0.06))
                    }
                    
                } else {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.proVideos) { proVideo in
                                ProTrickPreview(video: proVideo, cellSize: CGSize(width: 300, height: 500))
                            }
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.opacity(0.06))
                        }
                    }
                }
            }
        }
    }
}
