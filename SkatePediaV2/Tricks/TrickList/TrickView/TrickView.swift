//
//  TrickView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import SwiftUI

struct TrickView: View {
    @EnvironmentObject var trickListViewModel: TrickListViewModel
    @StateObject var viewModel = TrickViewModel()
    
    let userId: String
    let trick: Trick
    
    @State private var cellWidth: CGFloat = 0
    
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
                if case .idle = viewModel.trickItemFetchState {
                    await viewModel.fetchTrickItems(trickId: trick.id)
                }
                if case .idle = viewModel.proVideosFetchState {
                    await viewModel.fetchProVideosForTrick(trickId: trick.id)
                }
            }
        }

    }
    
    var learnFirstSection: some View {
        Section(header: Text("Learn First:").foregroundColor(.gray)) {
            VStack(alignment: .leading, spacing: 0) {
                HStack { Spacer() }

                Text(trick.learnFirst)
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .padding()
            .background(Color(uiColor: UIColor.systemBackground))
            .shadow(color: .primary.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
    
    var addTrickItemSection: some View {
        HStack(alignment: .center) {
            Spacer()
            
            CustomNavLink(
                destination: AddTrickItemView(
                    userId: userId,
                    trick: trick,
                    trickItems: $viewModel.trickItems
                )
                .environmentObject(trickListViewModel)
                .customNavBarItems(title: "Add Trick Item", subtitle: "\(trick.name)", backButtonHidden: false)
            ) {
                Text("Add Trick Item")
                    .font(.body)
                    .foregroundColor(.primary)
                Image(systemName: "plus.square")
                    .foregroundColor(Color("buttonColor"))
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal)
    }
    
    var trickItemsSection: some View {
        Section(header: Text("Trick Items:").foregroundColor(.gray)) {
            VStack {
                switch viewModel.trickItemFetchState {
                case .idle:
                    VStack { }
                    
                case .loading:
                    CustomProgressView(placement: .center)
                    
                case .success:
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
                            TrickItemCell(userId: userId, trickItem: trickItem, trick: trick, trickItems: $viewModel.trickItems)
                                .environmentObject(trickListViewModel)
                        }
                    }
                case .failure(let error):
                    VStack(alignment: .center) {
                        HStack { Spacer() }
                        
                        Text(error.errorDescription ?? "")
                            .font(.headline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            Task {
                                await viewModel.fetchTrickItems(trickId: trick.id)
                            }
                        } label: {
                            Text("Try Again")
                        }
                        .foregroundColor(Color("buttonColor"))
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("buttonColor"))
                        }
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.primary.opacity(0.05))
            }
        }
    }
    
    var proPreviewsSection: some View {
        Section(header: Text("Pro Videos:").foregroundColor(.gray)) {
            switch viewModel.proVideosFetchState {
                
            case .idle:
                VStack { }
                
            case .loading:
                CustomProgressView(placement: .center)

            case .success:
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
                            .fill(.primary.opacity(0.06))
                    }
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
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.primary.opacity(0.05))
                    }
                }
            case .failure(let error):
                VStack(alignment: .center) {
                    HStack { Spacer() }
                    
                    Text(error.errorDescription ?? "")
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        Task {
                            await viewModel.fetchProVideosForTrick(trickId: trick.id)
                        }
                    } label: {
                        Text("Try Again")
                    }
                    .foregroundColor(Color("buttonColor"))
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("buttonColor"))
                    }
                }
            }
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
