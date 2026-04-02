//
//  SettingsItemCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/5/26.
//

import SwiftUI

struct SettingsItemCell: View {
    var id: AnyHashable
    var header: String
    var description: String
    @Binding var value: Bool
    
    @EnvironmentObject private var manager: SettingsInfoManager
    
    var body: some View {
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
            
            Spacer()
            
            Toggle("", isOn: $value)
                .tint(Color.button)
        }
        .padding(.horizontal, 12)
    }
}
