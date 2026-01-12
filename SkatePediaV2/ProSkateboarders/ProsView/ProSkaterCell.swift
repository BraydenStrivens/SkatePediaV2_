//
//  ProSkaterCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import Kingfisher

struct ProSkaterCell: View {
    @EnvironmentObject var viewModel: ProViewModel
    let pro: ProSkater
    let borderColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            boldSearchMatchesCharacters(name: pro.name, searchText: viewModel.proSearchText)
                .font(.title3)
                .fontWeight(.semibold)
                .kerning(0.2)
            
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
    
    func boldSearchMatchesCharacters(name: String, searchText: String) -> Text {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedSearch.isEmpty else {
            return Text(pro.name)
        }
        
        let lowercaseName = pro.name.lowercased()
        let lowercaseSearch = trimmedSearch.lowercased()
        
        guard let range = lowercaseName.range(of: lowercaseSearch) else {
            return Text(pro.name)
        }
        
        let start = pro.name[..<range.lowerBound]
        let match = pro.name[range]
        let end = pro.name[range.upperBound...]
        
        return Text(start) + Text(match).fontWeight(.heavy) + Text(end)
    }
}

//#Preview {
//    ProSkaterCell()
//}
