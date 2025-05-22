//
//  ProTrickListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/11/25.
//

import SwiftUI

struct ProTricksListView: View {
    let trickList: [ProSkaterVideo]
    let allTricks: [ProSkaterVideo]
    
    var body: some View {
        VStack {
            if trickList.isEmpty {
                HStack {
                    Spacer()
                    Text("No tricks available...")
                    Spacer()
                }
            } else {
                ForEach(trickList) { proTrick in
                    CustomNavLink(destination: ProVideosView(videos: allTricks, selectedVideo: proTrick)) {
                        HStack {
                            Text(proTrick.trickName)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical, 5)
                    }
                    .foregroundColor(.primary)
                    
                    Divider()
                    
                    
                }
            }
        }
    }
}
