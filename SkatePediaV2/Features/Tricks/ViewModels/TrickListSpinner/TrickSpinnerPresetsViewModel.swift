//
//  TrickSpinnerPresetsViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import Foundation

/// View model responsible for managing Trick Spinner presets.
///
/// Handles persistence, retrieval, and mutation of user-created presets
/// using `UserDefaults`.
///
/// - Important: Presets are stored locally and encoded/decoded using JSON.
final class TrickSpinnerPresetsViewModel: ObservableObject {
    @Published var presets: [SpinnerPreset] = []
    
    private let key = "spinner_presets"
    
    init() {
        load()
    }
    
    /// Saves the current presets to local storage.
    ///
    /// Encodes the presets array and persists it to `UserDefaults`.
    func save() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    /// Loads presets from local storage.
    ///
    /// Decodes stored data from `UserDefaults` into the presets array.
    func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        
        if let decoded = try? JSONDecoder().decode([SpinnerPreset].self, from: data) {
            presets = decoded
        }
    }
    
    /// Adds a new preset and persists the updated list.
    ///
    /// - Parameters:
    ///   - newPreset: The preset to add.
    func addPreset(_ newPreset: SpinnerPreset) {
        presets.append(newPreset)
        save()
    }
    
    /// Updates an existing preset and persists the changes.
    ///
    /// - Parameters:
    ///   - updatedPreset: The preset with updated values.
    func updatePreset(_ updatedPreset: SpinnerPreset) {
        guard let index = presets.firstIndex(where: { $0.id == updatedPreset.id }) else { return }
        presets[index] = updatedPreset
        save()
    }
    
    /// Deletes a preset and persists the updated list.
    ///
    /// - Parameters:
    ///   - preset: The preset to delete.
    func deletePreset(_ preset: SpinnerPreset) {
        presets.removeAll(where: { $0.id == preset.id})
        save()
    }
}
