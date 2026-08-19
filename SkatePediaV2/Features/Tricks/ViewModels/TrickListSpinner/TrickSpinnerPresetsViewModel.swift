//
//  TrickSpinnerPresetsViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import Foundation

/// View model responsible for managing Trick Spinner presets.
///
/// `TrickSpinnerPresetsViewModel` coordinates:
/// - Loading persisted spinner presets from local storage
/// - Persisting preset changes to `UserDefaults`
/// - Adding, updating, and deleting presets
/// - Publishing preset changes for SwiftUI presentation
///
/// Persistence Design:
/// Presets are stored locally using `UserDefaults` and encoded/decoded
/// using `JSONEncoder` and `JSONDecoder`.
///
/// Concurrency Design:
/// This view model intentionally avoids full `@MainActor` isolation.
/// Encoding and decoding work are performed off the main actor whenever
/// possible, while SwiftUI-related state mutations are isolated to focused
/// `@MainActor` helper methods.
final class TrickSpinnerPresetsViewModel: ObservableObject {
    
    // MARK: Published State
    @Published var presets: [SpinnerPreset] = []
    
    // MARK: Private Properties
    private let key = "spinner_presets"
    
    // MARK: Init
    init() {
        load()
    }
    
    // MARK: MainActor Helpers

    /// Replaces the current presets array.
    ///
    /// - Parameter presets: The presets to display.
    @MainActor
    private func updatePresets(_ presets: [SpinnerPreset]) {
        self.presets = presets
    }

    /// Returns a snapshot of the current presets array.
    ///
    /// This snapshot allows encoding work to occur off the main actor.
    ///
    /// - Returns: The current presets.
    @MainActor
    private func presetsSnapshot() -> [SpinnerPreset] {
        presets
    }
    
    // MARK: Private Helpers

    /// Loads persisted presets from local storage.
    ///
    /// This method:
    /// - Reads encoded preset data from `UserDefaults`
    /// - Decodes stored JSON into `[SpinnerPreset]`
    /// - Applies decoded presets through a MainActor helper
    private func load() {
        Task {
            guard let data = UserDefaults.standard.data(forKey: key) else {
                return
            }

            guard let decoded = try? JSONDecoder()
                .decode([SpinnerPreset].self, from: data)
            else { return }

            await updatePresets(decoded)
        }
    }

    /// Persists the current presets array to local storage.
    ///
    /// This method:
    /// - Captures a snapshot of current presets
    /// - Encodes presets into JSON data off the main actor
    /// - Stores encoded data in `UserDefaults`
    private func save() async {
        let presets = await presetsSnapshot()

        guard let data = try? JSONEncoder().encode(presets) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: Public Actions

    /// Adds a new spinner preset.
    ///
    /// This method:
    /// - Appends the provided preset
    /// - Updates published UI state
    /// - Persists updated presets to local storage
    ///
    /// - Parameter newPreset: The preset to add.
    func addPreset(
        _ newPreset: SpinnerPreset
    ) async {
        let updatedPresets = await presetsSnapshot() + [newPreset]
        
        await updatePresets(updatedPresets)
        await save()
    }

    /// Updates an existing spinner preset.
    ///
    /// This method:
    /// - Replaces the matching preset
    /// - Updates published UI state
    /// - Persists updated presets to local storage
    ///
    /// - Parameter updatedPreset: The updated preset.
    func updatePreset(
        _ updatedPreset: SpinnerPreset
    ) async {
        var updatedPresets = await presetsSnapshot()
        
        guard let index = updatedPresets.firstIndex(
            where: { $0.id == updatedPreset.id }
        ) else {
            return
        }
        
        updatedPresets[index] = updatedPreset
        
        await updatePresets(updatedPresets)
        await save()
    }

    /// Deletes a spinner preset.
    ///
    /// This method:
    /// - Removes the matching preset
    /// - Updates published UI state
    /// - Persists updated presets to local storage
    ///
    /// - Parameter preset: The preset to delete.
    func deletePreset(
        _ preset: SpinnerPreset
    ) async {
        let updatedPresets = await presetsSnapshot()
            .filter { $0.id != preset.id }
        
        await updatePresets(updatedPresets)
        await save()
    }
}
