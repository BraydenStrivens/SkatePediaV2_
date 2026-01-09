//
//  SettingsItemCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/5/26.
//

import SwiftUI

struct SettingsItemCell: View {
    var settingHeader: String
    @Binding var buttonState: Bool
    
    var body: some View {
        HStack {
            Toggle(settingHeader, isOn: $buttonState)
                .tint(Color("buttonColor"))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        
        Divider()
    }
}

//#Preview {
//    SettingsItemCell(
//        settingHeader: "Use trick abbreviations:",
//        buttonState: false
//    )
//}
