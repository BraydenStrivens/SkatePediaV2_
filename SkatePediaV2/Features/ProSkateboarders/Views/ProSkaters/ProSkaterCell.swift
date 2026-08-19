//
//  ProSkaterCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/10/25.
//

import SwiftUI
import Kingfisher

/// A SwiftUI cell view representing a professional skater in a selectable list.
///
/// `ProSkaterCell` displays summary information about a professional skater,
/// including their name, stance, trick count, and profile image. It also
/// visually reflects selection state and highlights search matches within the
/// skater’s name.
///
/// - Parameters:
///   - pro: The professional skater being displayed.
///   - isSelected: A Boolean indicating whether this cell is currently selected.
struct ProSkaterCell: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var viewModel: ProsViewModel
    
    // MARK: Parameters
    let pro: ProSkater
    let isSelected: Bool
    
    // MARK: Body
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
    
    // MARK: Private Helpers
    
    /// Applies search-based text highlighting to a professional skater's name.
    ///
    /// This function:
    /// - Normalizes and trims the search text
    /// - Performs a case-insensitive substring match
    /// - Returns a composed `Text` view with matched characters emphasized
    ///
    /// - Parameters:
    ///   - name: The full name of the professional skater.
    ///   - searchText: The current search query input by the user.
    ///
    /// - Returns:
    /// A `Text` view where the matching substring is rendered in heavier font weight.
    private func boldSearchMatchesCharacters(name: String, searchText: String) -> Text {
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
