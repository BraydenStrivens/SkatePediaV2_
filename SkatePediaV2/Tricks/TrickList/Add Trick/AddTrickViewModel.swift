//
//  AddTrickViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import Foundation

/// Manages the data inputted by the user for uploading a new trick to their 'trick_list' collection.
/// Contains functions that validate the data, convert the data to the proper type for uploading,
/// and upload the data to Firebase. 
///
@MainActor
final class AddTrickViewModel: ObservableObject {
    
    @Published var trickName: String = ""
    @Published var abbreviatedName: String = ""
    @Published var difficulty: TrickDifficulty = .beginner
    @Published var learnFirst: [String] = []
    @Published var learnFirstAbbreviation: [String] = []
    @Published var addTrickState: RequestState = .idle

    var addButtonIsDisabled: Bool {
        trickName.isEmpty || learnFirst.isEmpty
    }
    
    /// Validates that the inputted 'Trick Name' and selected 'Learn First' tricks are not empty.
    /// If the user doesn't input an 'Abbreviated Trick Name', the abbreviation gets set to the trick name.
    ///
    /// - Throws: A FirestoreError with a custom error message that specifies what failed validation.
    ///
    private func validate() throws {
        guard !trickName.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SPError.custom("Please enter a trick name.")
        }
        guard !learnFirst.isEmpty else {
            throw SPError.custom("Please select at least one 'learn first' trick.")
        }
        if abbreviatedName.trimmingCharacters(in: .whitespaces).isEmpty {
            abbreviatedName = trickName
        }
    }
    
    /// Validates the inputted trick info and attempts to upload a new trick document to the users trick list collection.
    /// Updates the 'addTrickState' based on the state of the request. Updates the user's trick list info with the new
    /// trick upon successful upload.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - stance: The stance of the new trick being uploaded.
    ///  - trickListInfo: The trick list info of the current user.
    ///
    func addTrickToList(stance: TrickStance, trickList: [Trick]) -> Trick? {
        do {
            try validate()
            getLearnFirstTrickAbbreviations(trickList: trickList)
            
            let trick: Trick = Trick(
                id: UUID().uuidString,
                name: trickName,
                stance: stance,
                abbreviation: abbreviatedName,
                learnFirst: convertArrayToString(array: self.learnFirst),
                learnFirstAbbreviation: convertArrayToString(array: self.learnFirstAbbreviation),
                difficulty: difficulty
            )

            return trick
            
        } catch {
            addTrickState = .failure(mapToSPError(error: error))
        }
        return nil
    }
    
    /// Converts an array of 'Trick' objects into an array of Strings containing the names of each trick.
    ///
    /// - Parameters:
    ///  - trickList: 2D array of 'Trick' objects sorted by their 'difficulty' attribute
    ///
    /// - Returns: An array of strings containing the names of each trick in the users trick list.
    ///
    func getTrickNames(trickList: [Trick]) -> [String] {
        var trickNames: [String] = []
        
        for trick in trickList {
            trickNames.append(trick.name)
        }
        return trickNames
    }
    
    /// Each trick the user selects for the 'Learn First' tricks gets appended to an array. The 'Learn First' field
    /// in the trick's document is a string. This function converts the array of selected 'Learn First' tricks to a
    /// single string to be uploaded to the new trick's document.
    ///
    /// - Parameters:
    ///  - array: An array of trick names of the tricks to learn first for the new trick.
    ///
    /// - Returns: A string of each selected 'Learn First' trick names separated by a comma and space.
    ///
    func convertArrayToString(array: [String]) -> String {
        var string: String = ""

        if !array.isEmpty {
            for item in array {
                string += "\(item), "
            }
            
            // Remove the ", " at the end
            string.removeLast(2)
        }
        return string
    }
    
    /// Fetches the trick document for each selected 'Learn First' trick and appends their 'Abbreviated Trick Name'
    /// to an array.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///
    ///  - Throws: An error thrown from Firebase specifying why the tricks couldn't be fetched.
    ///
    func getLearnFirstTrickAbbreviations(trickList: [Trick]) {
        guard !learnFirst.isEmpty else { return }
        
        for trickName in learnFirst {
            let trickObj = trickList.first(where: { $0.name == trickName })
            
            if let trickObj = trickObj {
                learnFirstAbbreviation.append(trickObj.abbreviation)
            } else {
                learnFirstAbbreviation.append(trickName)
            }
        }
    }
}
