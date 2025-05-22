//
//  VideoPreviewSheetView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/12/25.
//

import SwiftUI
import AVKit

struct VideoPreviewSheetView: View {
    let video: AVPlayer
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                VideoPlayer(player: video)
                    .scaledToFit()
                    .frame(width: UIScreen.screenWidth)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        Task {
                            dismiss()
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding()
                }
            }
        }
    }
}

//#Preview {
//    VideoPreviewSheetView()
//}
