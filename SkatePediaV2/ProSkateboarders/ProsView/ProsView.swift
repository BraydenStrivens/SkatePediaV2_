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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .center, spacing: 10) {
                        if viewModel.proSkaters.isEmpty {
                            ProgressView()
                            
                        } else {
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
    }
}
