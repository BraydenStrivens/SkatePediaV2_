//
//  SettingsItemCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/5/26.
//

import SwiftUI

/// A reusable settings row that displays a header, an info button, and a toggle switch.
///
/// This view is intended to be used within a settings screen. Tapping the info button
/// shows contextual information about the setting using `SettingsInfoManager`.
///
/// - Parameters:
///   - id: A unique identifier for the setting row, used to track info button state.
///   - header: The title of the setting displayed on the left side.
///   - description: A textual description displayed when the info button is tapped.
///   - value: A binding to a boolean that controls the toggle state.
struct SettingsItemCell: View {
    var id: AnyHashable
    var header: String
    var description: String
    @Binding var value: Bool
    
    @EnvironmentObject private var manager: SettingsInfoManager
    
    var body: some View {
        HStack {
            HStack {
                Text(header)
                
                Button {
                    manager.show(id: id, description: description)
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: InfoButtonFramePreferenceKey.self,
                            value: [id:
                                        proxy.frame(in: .named("SettingsInfoSpace"))]
                        )
                    }
                )
                .tint(manager.isShown(id: id) ? .primary : .gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: $value)
                .labelsHidden()
                .fixedSize()
                .tint(Color.button)
        }
        .padding(.horizontal, 12)
    }
}
