//
//  AddTrickViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import Foundation
import FirebaseFirestore

/// View model responsible for creating and uploading a new Trick.
///
/// Manages user input, validates form data, converts input into the required
/// request format, and coordinates uploading to the backend and local store.
///
/// - Parameters:
///   - appEnv: Class containing global stores and services.
///   - errorStore: Used to present errors to the user.
@MainActor
final class AddTrickViewModel: ObservableObject {
    
    // MARK: Published State
    @Published var isUploading: Bool = false
    
    // MARK: Input State
    @Published var trickName: String = ""
    @Published var abbreviatedName: String = ""
    @Published var difficulty: TrickDifficulty = .beginner
    @Published var learnFirstTricks: [Trick] = []
    
    // MARK: Dependencies
    private let appEnv: AppEnvironment
    private let errorStore: ErrorStore
    
    // MARK: Derived Properties
    var addButtonIsDisabled: Bool {
        trickName.isEmpty || learnFirstTricks.isEmpty
    }
    
    // MARK: Init
    init(
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) {
        self.appEnv = appEnv
        self.errorStore = errorStore
    }
    
    // MARK: Private Helpers
    
    /// Validates user input before uploading a trick.
    ///
    /// Ensures required fields are populated and assigns a default
    /// abbreviation if none is provided.
    ///
    /// - Throws: `SPError` if validation fails.
    private func validate() throws {
        guard !trickName.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SPError.custom("Please enter a trick name.")
        }
        guard !learnFirstTricks.isEmpty else {
            throw SPError.custom("Please select at least one 'learn first' trick.")
        }
        if abbreviatedName.trimmingCharacters(in: .whitespaces).isEmpty {
            abbreviatedName = trickName
        }
    }
    
    // MARK: Public Actions
    
    /// Uploads a new trick to the backend and updates the local store.
    ///
    /// - Parameters:
    ///   - stance: The stance associated with the trick.
    ///   - trickList: The current list of tricks (used for context if needed).
    ///
    /// - Returns: `true` if upload succeeds, otherwise `false`.
    func uploadTrick(
        stance: TrickStance,
        trickList: [Trick]
    ) async -> Bool {
        isUploading = true
        defer { isUploading = false }
        
        do {
            try validate()
            
            let trickId = FirebaseHelpers.generateFirebaseId()
            let newTrick = Trick(
                id: trickId,
                name: trickName,
                stance: stance,
                abbreviation: abbreviatedName,
                learnFirst: convertArrayToString(array: learnFirstTricks, useAbbreviations: false),
                learnFirstAbbreviation: convertArrayToString(array: learnFirstTricks, useAbbreviations: true),
                difficulty: difficulty
            )
                        
            try await appEnv.trickListService.uploadTrick(newTrick)
            appEnv.trickListStore.uploadTrickLocally(newTrick: newTrick)
            
            return true
            
        } catch {
            errorStore.present(error, title: "Error Uploading Trick")
            return false
        }
    }

    /// Converts an array of `Trick` objects into a comma-separated string.
    ///
    /// - Parameters:
    ///   - array: The list of tricks to convert.
    ///   - useAbbreviations: Whether to use abbreviated names instead of full names.
    ///
    /// - Returns: A comma-separated string representation of the tricks.
    func convertArrayToString(
        array: [Trick],
        useAbbreviations: Bool
    ) -> String {
        var string: String = ""

        let names = array.map { $0.displayName(useAbbreviation: useAbbreviations) }
        
        if !names.isEmpty {
            for name in names {
                string += "\(name), "
            }
            
            // Remove the last ", " at the end
            string.removeLast(2)
        }
        return string
    }
}
