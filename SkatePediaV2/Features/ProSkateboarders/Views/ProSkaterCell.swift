//
//  ProSkaterCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import Kingfisher

/// A SwiftUI view representing a single pro skater.
///
/// Highlights portions of the pro's name that match the current search text
/// and visually indicates selection state.
struct ProSkaterCell: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var viewModel: ProsViewModel
    let pro: ProSkater
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            boldSearchMatchesCharacters(name: pro.name, searchText: viewModel.proSearchText)
                .font(.title3)
                .fontWeight(.semibold)
                .kerning(0.2)
            
            HStack {
                Text(pro.stance.camalCase)
                    .font(.subheadline)
                    .fontWeight(.regular)
                
                Spacer()
                
                Text("^[\(pro.numberOfTricks) trick](inflect: true)")
                    .font(.caption)
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
                .fill(colorScheme == .dark
                      ? isSelected ? Color(.systemGray5) : Color(.systemGray6)
                      : .white
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            .primary.opacity(colorScheme == .dark
                                             ? isSelected ? 0.4 : 0.2
                                             : 0),
                            .black.opacity(isSelected ? 0.6 : 0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: colorScheme == .dark
                        ? .black.opacity(0.6)
                        : .black.opacity(isSelected ? 0.5 : 0.4),
                        radius: isSelected ? 6 : 3,
                        y: 2
                )
        }
        .padding(21)
    }
    
    /// Highlights the part of the pro's name that matches the search text
    /// - Parameters:
    ///   - name: The full name of the pro
    ///   - searchText: The current search string
    /// - Returns: A SwiftUI `Text` view with matched substring in heavy font weight
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
