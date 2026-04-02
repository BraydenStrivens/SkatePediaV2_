//
//  AddTrickView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import SwiftUI

struct AddTrickView: View {
    @EnvironmentObject var userStore: UserStore
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.spSheetDismiss) private var dismissSheet
    
    @StateObject var viewModel: AddTrickViewModel
    
    let userId: String
    let stance: TrickStance
    let trickList: [Trick]
    
    init(
        userId: String,
        stance: TrickStance,
        trickList: [Trick],
        viewModel: AddTrickViewModel
    ) {
        self.userId = userId
        self.stance = stance
        self.trickList = trickList
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var useTrickAbbreviation: Bool {
        userStore.trickSettings?.useTrickAbbreviations == true
    }
    
    var body: some View {
        VStack(spacing: 20) {
            header
                .padding(.horizontal, 30)
                .padding(.vertical, 8)

            VStack(alignment: .center, spacing: 15) {
                TextField("Trick Name*", text: $viewModel.trickName)
                    .autocorrectionDisabled()
                
                Divider()
                
                TextField("Name Abbreviation?", text: $viewModel.abbreviatedName)
                    .autocorrectionDisabled()
                
                Divider()
                
                HStack {
                    Text("Difficulty:")
                    
                    Spacer()
                    
                    Menu(viewModel.difficulty.camalCase, systemImage: "chevron.down") {
                        ForEach(TrickDifficulty.allCases) { difficulty in
                            Button {
                                viewModel.difficulty = difficulty
                            } label: {
                                Text(difficulty.camalCase)
                            }
                        }
                    }
                    .tint(Color.accent)
                }
                Divider()
                
                selectLearnFirstSection
            }
            .padding()
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
            .padding()
            
            Spacer()
        }
    }
    
    var header: some View {
        HStack {
            Button("Cancel") {
                dismissSheet?()
            }
            .tint(.primary)
            
            Spacer()
            
            Button {
                Task {
                    let success = await viewModel.uploadTrick(
                        stance: stance,
                        trickList: trickList
                    )
                    
                    if success { dismissSheet?() }
                }
            } label: {
                if viewModel.isUploading {
                    ProgressView()
                    
                } else {
                    Text("Add")
                        .foregroundColor(viewModel.addButtonIsDisabled ?
                            .gray.opacity(0.6) : Color("buttonColor")
                        )
                        .disabled(viewModel.addButtonIsDisabled)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    /// Contains a menu with a popup list of all the trick names for the tricks in the current stance's trick list.
    /// The user can add or remove selected tricks from the 'learnFirst' array managed in the view model.
    ///
    var selectLearnFirstSection: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("Learn First:")
                
                Menu("", systemImage: "plus.square") {
                    ForEach(trickList) { trick in
                        Button {
                            let index = viewModel.learnFirstTricks
                                .firstIndex(where: { $0.id == trick.id })
                            if index == nil {
                                viewModel.learnFirstTricks.append(trick)
                            }
                        } label: {
                            Text(trick.displayName(useAbbreviation: useTrickAbbreviation))
                        }
                    }
                }
                .tint(Color.accent)
                
                Spacer()
                
                Button() {
                    let _ = viewModel.learnFirstTricks.popLast()
                } label: {
                    Image(systemName: "delete.backward")
                }
                .tint(Color.accent)
            }
            
            // Converts the array of selected tricks to a string for display in the view
            Text(
                viewModel.convertArrayToString(
                    array: viewModel.learnFirstTricks,
                    useAbbreviations: useTrickAbbreviation
                )
            )
            .font(.callout)
            .lineLimit(2)
            .multilineTextAlignment(.trailing)
            .foregroundStyle(.gray)
            .brightness(0.1)
        }
    }
}


//struct AddTrickView: View {
//    @EnvironmentObject var userStore: UserStore
//
//    @Environment(\.dismiss) private var dismiss
//    @Environment(\.colorScheme) private var colorScheme
//
//    @StateObject var viewModel: AddTrickViewModel
//
//    let userId: String
//    let stance: TrickStance
//    let trickList: [Trick]
//
//    init(
//        userId: String,
//        stance: TrickStance,
//        trickList: [Trick],
//        viewModel: AddTrickViewModel
//    ) {
//        self.userId = userId
//        self.stance = stance
//        self.trickList = trickList
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
//
//    var useTrickAbbreviation: Bool {
//        userStore.trickSettings?.useTrickAbbreviations == true
//    }
//
//    var body: some View {
//        NavigationStack {
//            VStack(alignment: .center, spacing: 15) {
//                TextField("Trick Name*", text: $viewModel.trickName)
//                    .autocorrectionDisabled()
//
//                Divider()
//
//                TextField("Name Abbreviation?", text: $viewModel.abbreviatedName)
//                    .autocorrectionDisabled()
//
//                Divider()
//
//                HStack {
//                    Text("Difficulty:")
//
//                    Spacer()
//
//                    Menu(viewModel.difficulty.camalCase, systemImage: "chevron.down") {
//                        ForEach(TrickDifficulty.allCases) { difficulty in
//                            Button {
//                                viewModel.difficulty = difficulty
//                            } label: {
//                                Text(difficulty.camalCase)
//                            }
//                        }
//                    }
//                    .tint(Color.accent)
//                }
//                Divider()
//
//                selectLearnFirstSection
//            }
//            .padding()
//            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
//            .padding()
//            .toolbar {
//                // Add trick button
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        Task {
//                            let success = await viewModel.uploadTrick(
//                                stance: stance,
//                                trickList: trickList
//                            )
//
//                            if success { dismiss() }
//                        }
//                    } label: {
//                        if viewModel.isUploading {
//                            ProgressView()
//
//                        } else {
//                            Text("Add")
//                                .foregroundColor(viewModel.addButtonIsDisabled ?
//                                    .gray.opacity(0.6) : Color("buttonColor")
//                                )
//                                .disabled(viewModel.addButtonIsDisabled)
//                                .font(.subheadline)
//                                .fontWeight(.semibold)
//                        }
//                    }
//                    .padding()
//                }
//                // Cancel button
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                    .disabled(viewModel.isUploading)
//                    .font(.subheadline)
//                    .foregroundColor(.primary)
//                    .padding()
//                }
//            }
//            Spacer()
//        }
//    }
//
//    /// Contains a menu with a popup list of all the trick names for the tricks in the current stance's trick list.
//    /// The user can add or remove selected tricks from the 'learnFirst' array managed in the view model.
//    ///
//    var selectLearnFirstSection: some View {
//        VStack(alignment: .trailing) {
//            HStack {
//                Text("Learn First:")
//
//                Menu("", systemImage: "plus.square") {
//                    ForEach(trickList) { trick in
//                        Button {
//                            let index = viewModel.learnFirstTricks
//                                .firstIndex(where: { $0.id == trick.id })
//                            if index == nil {
//                                viewModel.learnFirstTricks.append(trick)
//                            }
//                        } label: {
//                            Text(trick.displayName(useAbbreviation: useTrickAbbreviation))
//                        }
//                    }
//                }
//                .tint(Color.accent)
//
//                Spacer()
//
//                Button() {
//                    let _ = viewModel.learnFirstTricks.popLast()
//                } label: {
//                    Image(systemName: "delete.backward")
//                }
//                .tint(Color.accent)
//            }
//
//            // Converts the array of selected tricks to a string for display in the view
//            Text(
//                viewModel.convertArrayToString(
//                    array: viewModel.learnFirstTricks,
//                    useAbbreviations: useTrickAbbreviation
//                )
//            )
//            .font(.callout)
//            .lineLimit(2)
//            .multilineTextAlignment(.trailing)
//            .foregroundStyle(.gray)
//            .brightness(0.1)
//        }
//    }
//}
