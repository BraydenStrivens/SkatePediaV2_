//
//  ChangeTrickNameSheet.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/10/26.
//

import SwiftUI

/// A sheet view that allows users to customize a trick's display name and abbreviation.
///
/// `ChangeTrickNameSheet` provides editable text fields for updating a trick's
/// custom name and abbreviation, along with validation and async save handling.
///
/// Users may:
/// - Create or update a custom trick name.
/// - Create or update a custom abbreviation.
/// - Automatically use the custom name as the abbreviation.
/// - Remove an existing custom name configuration.
///
/// The sheet automatically dismisses after a successful save or removal.
struct ChangeTrickNameSheet: View {
    
    // MARK: Environment
    @Environment(\.spSheetDismiss) private var dismissSheet
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var errorStore: ErrorStore
    
    // MARK: State
    @FocusState private var focusedField: Field?
    @State private var newName: String = ""
    @State private var newAbbreviation: String = ""
    @State private var isLoading: Bool = false
    
    // MARK: Parameters
    let trick: Trick
    let onSave: (String?, String?) async -> Void
    let customNameAlreadyExists: Bool
    
    // MARK: Private Properties
    
    /// Focusable text fields within the sheet.
    private enum Field {
        case newName
        case newAbbreviation
    }
    
    // MARK: Init
    init(
        trick: Trick,
        onSave: @escaping (String?, String?) async -> Void
    ) {
        self.trick = trick
        self.onSave = onSave
        self.customNameAlreadyExists = (trick.customName != nil && trick.customAbbreviation != nil)
        
        _newName = State(initialValue: trick.customName ?? "")
        _newAbbreviation = State(initialValue: trick.customAbbreviation ?? "")
    }
    
    var body: some View {
        VStack {
            toolbar
                .padding(.vertical, 10)
                .padding(.horizontal)
                        
            VStack(spacing: 16) {
                Text("Update Trick Name")
                    .font(.title2)
                
                inputTextField(
                    text: $newName,
                    prompt: "New Name *",
                    focused: $focusedField,
                    equals: .newName
                )
                
                inputTextField(
                    text: $newAbbreviation,
                    prompt: "New Abbreviation (Optional)",
                    focused: $focusedField,
                    equals: .newAbbreviation
                )
                
                if customNameAlreadyExists {
                    Button("Remove") {
                        Task {
                            await onSave(nil, nil)
                            dismissSheet?()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .foregroundStyle(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(30)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
            .padding()
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
    
    // MARK: Functions
    
    /// Validates the entered trick name and abbreviation values.
    ///
    /// - Throws: `SPError.custom` if either field is empty.
    ///
    /// - Important: Validation must succeed before the save action executes.
    private func validateInput() throws {
        guard !newName.isEmpty else {
            throw SPError.custom("'New Name' field is required. Please enter a name.")
        }
        
        if newAbbreviation.isEmpty {
            newAbbreviation = newName
        }
    }
    
    // MARK: Subviews
    
    /// Creates a styled input field used for trick name editing.
    ///
    /// - Parameters:
    ///   - text: Binding to the editable text value.
    ///   - prompt: Placeholder text displayed when empty.
    ///   - focused: Focus binding used to control active field state.
    ///   - field: The field identifier associated with this text field.
    ///
    /// - Returns: A styled text input view with focus-aware border highlighting.
    private func inputTextField(
        text: Binding<String>,
        prompt: String,
        focused: FocusState<Field?>.Binding,
        equals field: Field
    ) -> some View {
        
        TextField("", text: text, prompt: Text(prompt))
            .autocorrectionDisabled()
            .focused(focused, equals: field)
            .frame(maxWidth: .infinity)
            .padding(14)
            .tint(Color.button)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(focused.wrappedValue == field ? Color.button : .gray.opacity(0.5))
            }
    }
    
    /// Toolbar displayed at the top of the sheet.
    ///
    /// Provides:
    /// - Cancel or remove actions.
    /// - The current trick name.
    /// - Save action with loading state.
    private var toolbar: some View {
        HStack {
            Button("Cancel") {
                dismissSheet?()
            }
            .tint(.primary)
            
//            Spacer()
        
            Text(userStore.getTrickName(trick))
                .frame(maxWidth: .infinity, alignment: .center)
        
//            Spacer()
            
            Button {
                isLoading = true
                
                Task {
                    do {
                        try validateInput()
                        await onSave(newName, newAbbreviation)
                        dismissSheet?()
                    } catch {
                        errorStore.present(error, title: "Error Updating Trick Name")
                    }
                    isLoading = false
                }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Save")
                        .foregroundStyle(Color.button)
                }
            }
        }
    }
}
