//
//  TrickSpinnerPresetsViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import Foundation

final class TrickSpinnerPresetsViewModel: ObservableObject {
    @Published var presets: [SpinnerPreset] = []
    
    private let key = "spinner_presets"
    
    init() {
        load()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        
        if let decoded = try? JSONDecoder().decode([SpinnerPreset].self, from: data) {
            presets = decoded
        }
    }
    
    func addPreset(_ newPreset: SpinnerPreset) {
        presets.append(newPreset)
        save()
    }
    
    func updatePreset(_ updatedPreset: SpinnerPreset) {
        guard let index = presets.firstIndex(where: { $0.id == updatedPreset.id }) else { return }
        presets[index] = updatedPreset
        save()
    }
    
    func deletePreset(_ preset: SpinnerPreset) {
        presets.removeAll(where: { $0.id == preset.id})
        save()
    }
}
