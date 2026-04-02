//
//  AddTrickViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import Foundation
import FirebaseFirestore

/// Manages the data inputted by the user for uploading a new trick to their 'trick_list' collection.
/// Contains functions that validate the data, convert the data to the proper type for uploading,
/// and upload the data to Firebase. 
///
@MainActor
final class AddTrickViewModel: ObservableObject {
    @Published var trickName: String = ""
    @Published var abbreviatedName: String = ""
    @Published var difficulty: TrickDifficulty = .beginner
    @Published var learnFirstTricks: [Trick] = []
    
    @Published var isUploading: Bool = false
    
    private let useCases: TrickListUseCases
    private let errorStore: ErrorStore
    
    init(
        useCases: TrickListUseCases,
        errorStore: ErrorStore
    ) {
        self.useCases = useCases
        self.errorStore = errorStore
    }
    
    var addButtonIsDisabled: Bool {
        trickName.isEmpty || learnFirstTricks.isEmpty
    }
    
    var addButtonEnabled: Bool {
        !trickName.isEmpty && !learnFirstTricks.isEmpty
    }
    
    /// Validates that the inputted 'Trick Name' and selected 'Learn First' tricks are not empty.
    /// If the user doesn't input an 'Abbreviated Trick Name', the abbreviation gets set to the trick name.
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
    
    func uploadTrick(stance: TrickStance, trickList: [Trick]) async -> Bool {
        isUploading = true
        defer { isUploading = false }
        
        do {
            try validate()
            
            let request = UploadTrickRequest(
                name: trickName,
                abbreviation: abbreviatedName,
                stance: stance,
                learnFirst: convertArrayToString(array: learnFirstTricks, useAbbreviations: false),
                learnFirstAbbreviation: convertArrayToString(array: learnFirstTricks, useAbbreviations: true),
                difficulty: difficulty
            )
            
            try await useCases.upload(request)
            return true
            
        } catch {
            errorStore.present(error, title: "Error Uploading Trick")
            return false
        }
    }

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
