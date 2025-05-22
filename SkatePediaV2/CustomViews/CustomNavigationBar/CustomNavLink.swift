//
//  CustomNavLink.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import SwiftUI

struct CustomNavLink<Label: View, Destination: View>: View {
    
    let destination: Destination
    let label: Label
    
    init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }
    
    var body: some View {
        NavigationLink(
            destination:
                CustomNavBarContainerView {
                    destination
                }
                .navigationBarHidden(true)
            ,
            label: {
                label
            }
        )
    }
}

#Preview {
    CustomNavView {
        CustomNavLink(
            destination: Text("Destination"),
            label: {
                Text("Navigate")
            })
    }
    
}
