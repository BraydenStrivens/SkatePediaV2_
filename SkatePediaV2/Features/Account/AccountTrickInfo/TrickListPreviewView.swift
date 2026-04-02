//
//  TrickListPreviewView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/10/25.
//

import SwiftUI

///
/// Struct that displays a preview of a users progress of the trick list. Sorts the users trick list based on their progress and displays each trick.
///
///  - Parameters:
///   - userId: The id of a user in the database.
///   - stance: The skateboard stance of a user.
///
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

///
/// Displays a list of tricks belonging to a user.
///
/// - Parameters:
///  - trickList: An array containing 'Trick' objects belonging to a user. 
///
struct ListViewByRating: View {
    let trickList: [Trick]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(trickList) { trick in
                Text(trick.name)
                    .offset(x: 30)
                
                Divider()
            }
        }
    }
}
