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
    @StateObject var viewModel = TrickListPreviewViewModel()
    
    let userId: String
    let stance: String

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(spacing: 10) {
                    if !viewModel.threeStarTricks.isEmpty {
                        VStack {
                            TrickStarRatingView(rating: 3, size: 30)
                            Divider()
                            ListViewByRating(trickList: viewModel.threeStarTricks)
                        }
                        .padding(.vertical)
                    }
                    
                    if !viewModel.twoStarTricks.isEmpty {
                        VStack {
                            TrickStarRatingView(rating: 2, size: 30)
                            Divider()
                            ListViewByRating(trickList: viewModel.twoStarTricks)
                        }
                        .padding(.vertical)
                    }
                    
                    if !viewModel.oneStarTricks.isEmpty {
                        VStack {
                            TrickStarRatingView(rating: 1, size: 30)
                            Divider()
                            ListViewByRating(trickList: viewModel.oneStarTricks)
                        }
                        .padding(.vertical)
                    }
                    
                    if !viewModel.zeroStarTricks.isEmpty {
                        VStack {
                            TrickStarRatingView(rating: 0, size: 30)
                            Divider()
                            ListViewByRating(trickList: viewModel.zeroStarTricks)
                        }
                        .padding(.vertical)
                    }
                    
                    if !viewModel.unstartedStarTricks.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Not Started")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Divider()
                            
                            ListViewByRating(trickList: viewModel.unstartedStarTricks)
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .padding()
        .customNavBarItems(title: "\(stance) Tricks", subtitle: "", backButtonHidden: false)
        .onAppear {
            Task {
                try await viewModel.fetchTrickList(userId: userId, stance: stance)
            }
        }
    }
}

///
/// Displays three stars that are filled and colored according to a user's self rating of that trick.
///
/// - Parameters:
///  - rating: an integer from [0,3] representing a user's mastery of a trick.
///
struct TrickStarRatingView: View {
    let rating: Int
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: rating > 0 ? "star.fill" : "star")
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(rating > 0 ? .yellow : .primary)
            
            Image(systemName: rating > 1 ? "star.fill" : "star")
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(rating > 1 ? .yellow : .primary)

            Image(systemName: rating > 2 ? "star.fill" : "star")
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(rating > 2 ? .yellow : .primary)
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
