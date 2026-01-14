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
    @EnvironmentObject var trickListViewModel: TrickListViewModel
    @StateObject var viewModel = AddTrickViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let userId: String
    let stance: String
    let trickList: [[Trick]]
    let trickListInfo: TrickListInfo
    
    private let difficulties: [String] = ["Easy", "Intermediate", "Advanced"]
    
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
                        
                    Menu(viewModel.difficulty, systemImage: "chevron.down") {
                        ForEach(difficulties, id: \.self) { difficulty in
                            Button {
                                viewModel.difficulty = difficulty
                            } label: {
                                Text(difficulty)
                            }
                        }
                    }
                }
                Divider()
                
                selectLearnFirstSection
            }
            .customNavBarItems(title: "Add Trick", subtitle: "", backButtonHidden: false)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                    .fill(Color(uiColor: UIColor.systemBackground))
            }
            .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 3)
            .padding()
            .toolbar {
                // Add trick button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.addTrickToList(userId: userId, stance: stance, trickListInfo: trickListInfo)
                            
                            // Closes the sheet and re-fetches the user's trick list
                            // data if the upload is successful
                            if case .success = viewModel.addTrickState {
                                dismiss()
                                await trickListViewModel.loadTrickListView(userId: userId)
                            }
                        }
                    } label: {
                        if case .loading = viewModel.addTrickState {
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
            Button("OK", role: .cancel) {
                viewModel.addTrickState = .idle
            }
        } message: {
            Text(viewModel.addTrickState.error?.errorDescription ?? "")
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
                            viewModel.learnFirst.append(name)
                        } label: {
                            Text(name)
                        }
                    }
                }
                Spacer()
                
                Button(role: .destructive) {
                    let _ = viewModel.learnFirst.popLast()
                } label: {
                    Image(systemName: "delete.backward")
                }
            }
            
            // Converts the array of selected tricks to a string for display in the view
            Text(viewModel.convertArrayToString(array: viewModel.learnFirst))
                .frame(height: 20)
                .font(.caption)
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
        }
    }
}
