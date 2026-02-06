//
//  AddTrickView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import SwiftUI

/// A custom view containing various input fields the user can fill out to create a new trick.
/// This view requires a 'TrickListViewModel' object to be present in the environment that
/// is used to re-fetch the user's trick list after uploading a new trick.
///
/// This view contains a required input field for the new trick's name, an optional input field for the
/// new trick's abbreviated name, a menu for selecting the tricks difficulty, and another menu for
/// selecting tricks that should be learned first before learning the new trick. This view contains
/// an error popup that informs the user if the upload failed. Data for the input fields are managed
/// in a view model.
///
/// - Parameters:
///  - userId: The id of the current user.
///  - stance: The stance of the new trick.
///  - trickList: 2D array of 'Trick' objects for a given stance that is sorted by difficulty.
///  - trickListInfo: A struct containing info about the user's trick list
///
struct AddTrickView: View {
    @EnvironmentObject var trickListVM: TrickListViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel = AddTrickViewModel()
    
    let stance: TrickStance
    let trickList: [Trick]
    
    private let difficulties: [String] = ["Beginner", "Intermediate", "Advanced"]
    
    var body: some View {
        NavigationStack {
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
                }
                Divider()
                
                selectLearnFirstSection
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorScheme == .dark ? Color(.systemGray5) : .white)
                    .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.5),
                            radius: 4,
                            y: 3
                    )
            }
            .padding()
            .toolbar {
                // Add trick button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            let newTrick = viewModel.addTrickToList(
                                stance: stance,
                                trickList: trickList
                            )
                            if let newTrick = newTrick {
                                dismiss()
                                await trickListVM.addTrick(newTrick: newTrick)
                            }
                        }
                    } label: {
                        Text("Add")
                            .foregroundColor(viewModel.addButtonIsDisabled ?
                                .gray.opacity(0.6) : Color("buttonColor")
                            )
                            .disabled(viewModel.addButtonIsDisabled)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding()
                }
                // Cancel button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding()
                }
            }
            Spacer()
        }
        .alert("Error Adding Trick",
               isPresented: .constant(viewModel.addTrickState.hasError)
        ) {
            Button("OK", role: .cancel) { viewModel.addTrickState = .idle }
            
        } message: {
            Text(viewModel.addTrickState.error?.errorDescription ?? "Something went wrong...")
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
                    let trickNames: [String] = viewModel.getTrickNames(trickList: trickList)
                    
                    ForEach(trickNames, id: \.self) { name in
                        Button {
                            // Append trick if not already in array
                            let index = viewModel.learnFirst.firstIndex(where: { $0 == name })
                            if index == nil {
                                viewModel.learnFirst.append(name)
                            }
                        } label: {
                            Text(name)
                        }
                    }
                }
                
                Spacer()
                
                Button() {
                    let _ = viewModel.learnFirst.popLast()
                } label: {
                    Image(systemName: "delete.backward")
                }
                .tint(Color.accent)
            }
            
            // Converts the array of selected tricks to a string for display in the view
            Text(viewModel.convertArrayToString(array: viewModel.learnFirst))
                .font(.callout)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.gray)
                .brightness(0.1)
        }
    }
}
