//
//  TrickListPreviewView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/10/25.
//

import SwiftUI

/// View displaying a preview of a user's trick list progress.
///
/// Fetches and groups tricks by rating, presenting them
/// in sections for quick overview of progress by stance.
///
/// - Parameters:
///   - userId: The ID of the user whose tricks are being fetched.
///   - stance: The stance used to filter the trick list.
struct TrickListPreviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel = TrickListPreviewViewModel()
    
    private let highestRatings: [Int?] = [3, 2, 1, 0, nil]
    
    let userId: String
    let stance: TrickStance
    
    var body: some View {
        Group {
            switch viewModel.requestState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(highestRatings, id: \.self) { rating in
                            let sortedList = viewModel.trickList
                                .filter { $0.progressCounts.highestRating == rating }
                            
                            if !sortedList.isEmpty {
                                ratingListCard(
                                    rating: rating,
                                    sortedList: sortedList
                                )
                                .padding(15)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)

            case .failure(let sPError):
                ContentUnavailableView(
                    "Error Fetching Tricks",
                    systemImage: "exclamationmark.triangle",
                    description: Text(sPError.errorDescription ?? "Something went wrong...")
                )
            }
        }
        .task {
            await viewModel.fetchTrickList(userId: userId, stance: stance)
        }
    }
    
    /// Displays a section of tricks for a specific rating.
    ///
    /// - Parameters:
    ///   - rating: The rating level used to group tricks.
    ///   - sortedList: The list of tricks matching the rating.
    func ratingListCard(rating: Int?, sortedList: [Trick]) -> some View {
        VStack(alignment: .leading) {
            if let rating {
                TrickStarRatingView(
                    color: .yellow,
                    rating: rating,
                    size: 15
                )
            } else {
                Text("Not Started:")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            VStack(spacing: 10) {
                if !sortedList.isEmpty {
                    ForEach(sortedList) { trick in
                        Text(trick.name)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if trick != sortedList.last! {
                            Divider()
                        }
                    }
                }
            }
            .padding()
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
    }
}
