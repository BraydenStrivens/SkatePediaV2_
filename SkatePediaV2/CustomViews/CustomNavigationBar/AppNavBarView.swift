//
//  AppNavBarView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import SwiftUI

struct AppNavBarView: View {
    var body: some View {
        
        CustomNavView {
            ZStack {
                Color.orange.ignoresSafeArea()
                
                CustomNavLink(
                    destination: Text("Destination"),
                    label: {
                        Text("Navigate")
                    })
            }
//            .customNavigationTitle("Custom Title")
//            .customNavigationBackButtonHidden(true)
            .customNavBarItems(title: "New Title!", subtitle: "", backButtonHidden: true)
        }
    }
}

extension AppNavBarView {
    private var defaultNavView: some View {
        NavigationView {
            ZStack {
                Color.green.ignoresSafeArea()
                
                NavigationLink(
                    destination:
                        Text("Destination")
                        .navigationTitle("Title 2")
                        .navigationBarBackButtonHidden(false)
                    ,
                    label: {
                        Text("Navigate")
                    })
            }
            .navigationTitle("Nav Title Here")
        }
    }
}

#Preview {
    AppNavBarView()
}
