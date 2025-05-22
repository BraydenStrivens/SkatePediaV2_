//
//  SelectTrickItemSheetView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/25.
//

import SwiftUI

struct SelectTrickItemView: View {
    @StateObject var viewModel = SelectTrickItemViewModel()
    @Environment(\.dismiss) var dismiss
    @State var dummySelectedTrickItem: TrickItem? = nil
    
    @Binding var selectedTrickItem: TrickItem?
    let trickId: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if viewModel.loading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        if viewModel.trickItems.isEmpty {
                            HStack {
                                Spacer()
                                Text("No trick items uploaded for trick")
                                Spacer()
                            }
                        } else {
                            ForEach(viewModel.trickItems) { trickItem in
                                SelectTrickItemCell(user: viewModel.currentUser, trickItem: trickItem, selectedTrickItem: $dummySelectedTrickItem)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Trick Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.selectedTrickItem = dummySelectedTrickItem
                        dismiss()
                    } label: {
                        Text("Continue")
                            .foregroundColor(.primary.opacity(dummySelectedTrickItem == nil ? 0.4 : 1))
                    }
                    .disabled(dummySelectedTrickItem == nil)
                }
            }
            .onFirstAppear {
                Task {
                    if !viewModel.fetched { try await viewModel.fetchTrickItemsForTrick(trickId: trickId) }
                }
            }
        }
    }
}

