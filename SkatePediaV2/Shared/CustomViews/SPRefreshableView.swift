//
//  SPRefreshableView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/19/26.
//

import SwiftUI

struct SPRefreshableView<Content: View>: View {
    
    @State private var isRefreshing: Bool = false
    
    let content: Content
    let refreshAction: () async -> Void
    
    init(
        @ViewBuilder content: () -> Content,
        refreshAction: @escaping () async -> Void
    ) {
        self.content = content()
        self.refreshAction = refreshAction
    }
    
    var body: some View {
        VStack {
            if isRefreshing {
                CustomProgressView(placement: .center)
                    .frame(height: 50)
                
                content

            }
        }
    }
}
