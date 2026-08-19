//
//  AddTrickView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import SwiftUI

/// A view used to create and upload a new Trick to the user's trick list.
///
/// Provides a form for entering a trick name, optional abbreviation, selecting difficulty,
/// and defining prerequisite tricks ("learn first").
///
/// Coordinates with `AddTrickViewModel` to validate input and handle upload logic.
///
/// On successful upload, the view is dismissed.
///
/// - Important:
///   Requires a valid `stance` and existing `trickList` for selecting prerequisite tricks.
///
/// - Parameters:
///   - userId: The ID of the current user.
///   - stance: The stance associated with the new trick.
///   - trickList: The list of existing tricks available for "learn first" selection.
///   - viewModel: View model responsible for validation and upload logic.
struct AddTrickView: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.spSheetDismiss) private var dismissSheet
    @EnvironmentObject private var userStore: UserStore
    
    // MARK: State
    @FocusState private var focusedField: Field?
    
    // MARK: Parameters
    @StateObject var viewModel: AddTrickViewModel
    let userId: String
    let stance: TrickStance
    let trickList: [Trick]
    
    // MARK: Private Properties
    
    /// Focusable text fields within the sheet.
    private enum Field {
        case name
        case abbreviatedName
    }
    
    // MARK: Init
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
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 20) {
            header
                .padding(.horizontal, 30)
                .padding(.vertical, 8)

            inputBox
                .padding()
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
                .padding()
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onAppear {
            focusedField = .name
        }
        .onTapGesture {
            focusedField = nil
        }
    }
    
    // MARK: Subviews
    
    /// Header containing cancel and submit actions.
    ///
    /// - Important:
    ///   Upload button is disabled while validation fails or upload is in progress.
    private var header: some View {
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
    
    /// Box container inputs for the user to type the new trick's name and abbreviation, select the difficulty,
    /// and select the list of tricks to learn first.
    private var inputBox: some View {
        VStack(alignment: .center, spacing: 15) {
            
            Group {
                // Required input for the trick's full name.
                TextField("Trick Name *", text: $viewModel.trickName)
                    .focused($focusedField, equals: .name)
                
                Divider()
                
                // Optional abbreviation input for display purposes.
                TextField("Name Abbreviation (Optional)", text: $viewModel.abbreviatedName)
                    .focused($focusedField, equals: .abbreviatedName)
            }
            .autocorrectionDisabled()
            .tint(Color.button)
            
            Divider()
            
            // Difficulty selection menu.
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
    }
    
    /// Section for selecting prerequisite tricks ("learn first").
    ///
    /// Allows the user to:
    /// - Add tricks from the current trick list
    /// - Remove the most recently added trick
    /// - View selected tricks as a formatted string
    ///
    /// - Important:
    ///   Prevents duplicate entries in the `learnFirstTricks` array.
    private var selectLearnFirstSection: some View {
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
                            Text(userStore.getTrickName(trick))
                        }
                    }
                }
                .tint(Color.accent)
                
                Spacer()
                
                /// Removes the most recently added prerequisite trick.
                Button() {
                    let _ = viewModel.learnFirstTricks.popLast()
                } label: {
                    Image(systemName: "delete.backward")
                }
                .tint(Color.accent)
            }
            
            /// Displays selected prerequisite tricks as a comma-separated string.
            Text(
                viewModel.convertArrayToString(
                    array: viewModel.learnFirstTricks,
                    useAbbreviations: userStore.trickSettings?.useTrickAbbreviations == true
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
