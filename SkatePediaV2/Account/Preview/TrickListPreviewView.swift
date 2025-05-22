//
//  TrickListPreviewView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/10/25.
//

import SwiftUI

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
                            TrickStarRatingView(rating: 3)
                            Divider()
                            ListViewByRating(trickList: viewModel.threeStarTricks)
                        }
                        .padding(.vertical)
                    }
                    if !viewModel.twoStarTricks.isEmpty {
                        VStack {
                            TrickStarRatingView(rating: 2)
                            Divider()
                            ListViewByRating(trickList: viewModel.twoStarTricks)
                        }
                        .padding(.vertical)
                    }
                    if !viewModel.oneStarTricks.isEmpty {
                        VStack {
                            TrickStarRatingView(rating: 1)
                            Divider()
                            ListViewByRating(trickList: viewModel.oneStarTricks)
                        }
                        .padding(.vertical)
                    }
                    if !viewModel.zeroStarTricks.isEmpty {
                        VStack {
                            TrickStarRatingView(rating: 0)
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

struct TrickStarRatingView: View {
    let rating: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: rating > 0 ? "star.fill" : "star")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(rating > 0 ? .yellow : .primary)
            
            Image(systemName: rating > 1 ? "star.fill" : "star")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(rating > 1 ? .yellow : .primary)

            Image(systemName: rating > 2 ? "star.fill" : "star")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(rating > 2 ? .yellow : .primary)
            
            Spacer()
        }
    }
}

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
