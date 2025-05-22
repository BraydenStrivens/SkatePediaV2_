//
//  SelectTrickView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI
import SlidingTabView

struct SelectTrickView: View {
    @StateObject var viewModel = SelectTrickViewModel()
    @State var tabIndex = 0
    
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTrick: Trick? {
        didSet {
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                // Sections for each stance
                SlidingTabView(
                    selection: $tabIndex,
                    tabs: ["Regular", "Fakie", "Switch", "Nollie"],
                    animation: .easeInOut,
                    activeAccentColor: .blue,
                    activeTabColor: .gray.opacity(0.2)
                )
                .foregroundColor(.primary)
                .padding()
                
                switch tabIndex {
                case 0:
                    VStack {
                        List {
                            ForEach(viewModel.regularTricks) { trick in
                                Text(trick.name)
                                    .foregroundColor(.primary)
                                    .fontWeight(selectedTrick == trick ? .bold : .regular)
                                    .onTapGesture {
                                        selectedTrick = trick
                                    }
                            }
                        }
                    }
                case 1:
                    VStack {
                        List {
                            ForEach(viewModel.fakieTricks) { trick in
                                Text(trick.name)
                                    .foregroundColor(.primary)
                                    .fontWeight(selectedTrick == trick ? .bold : .regular)
                                    .onTapGesture {
                                        selectedTrick = trick
                                    }
                            }
                        }
                    }
                case 2:
                    VStack {
                        List {
                            ForEach(viewModel.switchTricks) { trick in
                                Text(trick.name)
                                    .foregroundColor(.primary)
                                    .fontWeight(selectedTrick == trick ? .bold : .regular)
                                    .onTapGesture {
                                        selectedTrick = trick
                                    }
                            }
                        }
                    }
                case 3:
                    VStack {
                        List {
                            ForEach(viewModel.nollieTricks) { trick in
                                Text(trick.name)
                                    .foregroundColor(.primary)
                                    .fontWeight(selectedTrick == trick ? .bold : .regular)
                                    .onTapGesture {
                                        selectedTrick = trick
                                    }
                            }
                        }
                    }
                default:
                    Text("No stance selected")
                }
            }
            .navigationTitle("Select Trick")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                }
            }
        }
    }
}

//#Preview {
//    SelectTrickView()
//}
