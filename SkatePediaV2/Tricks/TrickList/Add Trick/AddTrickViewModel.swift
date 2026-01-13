//
//  AddTrickViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import Foundation

@MainActor
final class AddTrickViewModel: ObservableObject {
    
    @Published var trickName: String = ""
    @Published var abbreviatedName: String = ""
    @Published var difficulty: String = "Easy"
    @Published var learnFirst: [String] = []
    @Published var learnFirstAbbreviation: [String] = []
    
    @Published var errorMessage: String = ""
    @Published var addTrickState: RequestState = .idle
    
    private func validate() -> Bool {
        
        guard !trickName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        guard !learnFirst.isEmpty else {
            return false
        }
        
        if abbreviatedName.trimmingCharacters(in: .whitespaces).isEmpty {
            abbreviatedName = trickName
        }
        
        return true
    }
    
    func addTrickToList(userId: String, stance: String, trickListInfo: TrickListInfo) async throws {
        if validate() {
            do {
                addTrickState = .loading
                
                fetchTrickAbbreviations(userId: userId)
                
                let trick: Trick = Trick(
                    id: assignNextTrickId(stance: stance, trickListInfo: trickListInfo),
                    name: trickName,
                    stance: stance,
                    abbreviation: abbreviatedName,
                    learnFirst: convertArrayToString(array: learnFirst),
                    learnFirstAbbreviation: convertArrayToString(array: learnFirstAbbreviation),
                    difficulty: difficulty,
                    progress: []
                )
                
                try await TrickListManager.shared.uploadNewTrick(userId: userId, trick: trick, trickListInfo: trickListInfo)
                
                addTrickState = .success
            }
        }
    }
    
    func getTrickNames(trickList: [[Trick]]) -> [String] {
        var trickNames: [String] = []
        
        for list in trickList {
            for trick in list {
                trickNames.append(trick.name)
            }
        }
        
        return trickNames
    }
    
    func convertArrayToString(array: [String]) -> String {
        var string: String = ""

        if !array.isEmpty {
            for item in array {
                string += "\(item), "
            }
            
            string.removeLast(2)
        }
        
        return string
    }
    
    func fetchTrickAbbreviations(userId: String) {
        var fetchedTricks: [Trick]? = nil
        
        Task {
            fetchedTricks = try await TrickListManager.shared.fetchTricksByName(userId: userId, trickNameList: learnFirst)
        }
        
        if let fetchedTricks = fetchedTricks {
            for trick in fetchedTricks {
                learnFirstAbbreviation.append(trick.abbreviation)
            }
        }
    }
    
    func assignNextTrickId(stance: String, trickListInfo: TrickListInfo) -> String {
        let trickId: String
        
        switch(stance) {
        case Stance.Stances.regular.rawValue:
            trickId = "000000\(trickListInfo.totalRegularTricks)"
        case Stance.Stances.fakie.rawValue:
            trickId = "0000\(trickListInfo.totalFakieTricks + 1)00"
        case Stance.Stances._switch.rawValue:
            trickId = "00\(trickListInfo.totalSwitchTricks + 1)0000"
        case Stance.Stances.nollie.rawValue:
            trickId = "\(trickListInfo.totalNollieTricks + 1)000000"
        default:
            trickId = ""
        }
        
        return trickId
    }
}
