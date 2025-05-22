//
//  CustomNavBarContainerView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import SwiftUI

struct CustomNavBarContainerView<Content: View>: View {
    
    let content: Content
    
    @State private var showBackButton: Bool = true
    @State private var title: String = ""
    @State private var subtitle: String? = nil
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBarView(showBackButton: showBackButton, title: title, subtitle: subtitle)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .onPreferenceChange(CustomNavBarTitlePreferenceKeys.self, perform: { value in
            self.title = value
        })
        .onPreferenceChange(CustomNavBarSubtitlePreferenceKeys.self, perform: { value in
            self.subtitle = value
        })
        .onPreferenceChange(CustomNavBarBackButtonHiddenPreferenceKeys.self, perform: { value in
            self.showBackButton = !value
        })
    }
}

#Preview {
    CustomNavBarContainerView {
        ZStack {
            Color.green.ignoresSafeArea()
            
            Text("Hello World")
                .foregroundColor(.white)
                .customNavigationTitle("New Title")
                .customNavigationSubtitle("New Subtitle")
                .customNavigationBackButtonHidden(true)
        }
    }
}
