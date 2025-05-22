//
//  ProSkaterCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import Kingfisher

struct ProSkaterCell: View {
    let pro: ProSkater
    let borderColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(pro.name)
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack {
                Text(pro.stance)
                    .font(.subheadline)
                    .fontWeight(.regular)
                
                Spacer()
                
                if pro.numberOfTricks == 1 {
                    Text("1 trick")
                        .font(.caption)
                } else {
                    Text("\(pro.numberOfTricks) tricks")
                        .font(.caption)
                }
            }
            
            HStack {
                Spacer()
                KFImage(URL(string: pro.photoUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                
                Spacer()
            }
        }
        .foregroundColor(.primary)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(borderColor, lineWidth: 1)
        }
        .padding()
    }
}

//#Preview {
//    ProSkaterCell()
//}
