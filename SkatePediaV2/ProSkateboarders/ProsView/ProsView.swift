//
//  ProsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

struct ProsView: View {
    @StateObject var viewModel = ProViewModel()
    
    var body: some View {
        switch viewModel.fetchState {
        case .idle:
            VStack {}
            
        case .loading:
            CustomProgressView(placement: .center)
            
        case .success:
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    searchBar
                    
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(alignment: .center, spacing: 10) {
                            if viewModel.filteredProSkaters.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("No pro skaters matching '\(viewModel.proSearchText)'")
                                    Spacer()
                                }
                                .frame(width: UIScreen.screenWidth, height: 100)
                                
                            } else {
                                ForEach(viewModel.filteredProSkaters) { pro in
                                    let isSelected = viewModel.selectedPro == pro
                                    
                                    ProSkaterCell(
                                        pro: pro,
                                        borderColor: isSelected ? Color("buttonColor") : .gray
                                    )
                                    .environmentObject(viewModel)
                                    .onTapGesture {
                                        viewModel.selectedPro = pro
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    ZStack {
                        if let selectedPro = viewModel.selectedPro {
                            ProVideosListView(proSkater: selectedPro)
                                .id(selectedPro.id)
                                .transition(.asymmetric(
                                    insertion: .slide.combined(with: .opacity),
                                    removal: .slide.combined(with: .opacity)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.5), value: viewModel.selectedPro)

                }
                
                Spacer()
            }
            .padding()
            
        case .failure(let firestoreError):
            VStack {
                Spacer()
                Text(firestoreError.errorDescription ?? "Something went wrong...")
                
                Button {
                    Task {
                        await viewModel.fetchProSkaters()
                    }
                } label: {
                    Text("Try Again")
                }
                .foregroundColor(Color("buttonColor"))
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("buttonColor"))
                }
                Spacer()
            }
        }
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(viewModel.proSearchText.isEmpty ? .gray : .primary)
            
            TextField("Search pros", text: $viewModel.proSearchText)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .textContentType(.none)
                .lineLimit(1)
        }
        .onChange(of: viewModel.proSearchText) { _, _ in
            viewModel.filterProsArray()
        }
    }
}
