//
//  TrickItemSettingsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/16/25.
//

import SwiftUI

struct TrickItemSettingsView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Currently Unavailable")
                Spacer()
            }
            Spacer()        }
        .customNavBarItems(title: "Trick Item Settings", subtitle: "", backButtonHidden: false)
    }
}

#Preview {
    TrickItemSettingsView()
}
