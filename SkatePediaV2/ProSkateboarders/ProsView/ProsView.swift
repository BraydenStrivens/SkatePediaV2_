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
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(alignment: .center, spacing: 10) {
                            ForEach(viewModel.proSkaters) { pro in
                                let isSelected = viewModel.proSkaters.firstIndex(of: pro) == viewModel.selectedProIndex
                                
                                ProSkaterCell(
                                    pro: pro,
                                    borderColor: isSelected ? .primary : .gray
                                )
                                .onTapGesture {
                                    viewModel.selectedProIndex = viewModel.proSkaters.firstIndex(of: pro)!
                                }
                            }
                        }
                    }
                    
                    Divider()

                    ForEach(viewModel.proSkaters) { pro in
                        if viewModel.selectedProIndex == viewModel.proSkaters.firstIndex(of: pro)! {
                            ProVideosListView(proSkater: viewModel.proSkaters[viewModel.selectedProIndex])
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            
        case .failure(let firestoreError):
            VStack {
                Spacer()
                Text(firestoreError.errorDescription ?? "Error...")
                
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
}
