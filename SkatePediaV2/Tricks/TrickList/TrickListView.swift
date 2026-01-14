//
//  TrickListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI
import SlidingTabView

struct TrickListView: View {
    @StateObject var viewModel = TrickListViewModel()
    @State private var tabIndex: Int = 0
    
    private let tabs = ["Regular", "Fakie", "Switch", "Nollie"]
    
    var body: some View {
        VStack {
            switch viewModel.getTrickListFetchState {
            case .idle:
                VStack { }
                
            case .loading:
                ProgressView()
                
            case .success:
                VStack {
                    let _ = print(viewModel.trickListInfo)
                    // Displays total tricks learned bar
                    TrickListInfoView(stance: "", trickListInfo: viewModel.trickListInfo)
                    
                    // Sections for each stance
                    VStack {
                        HStack(spacing: 0) {
                            Spacer()
                            ForEach(tabs, id: \.self) { tab in
                                let index = tabs.firstIndex(of: tab)
                                let isCurrentTab = index == tabIndex
                                
                                VStack {
                                    Text(tab)
                                        .font(.headline)
                                        .fontWeight(isCurrentTab ? .semibold : .regular)
                                        .frame(width: UIScreen.screenWidth * 0.23, height: 50)
                                        .background {
                                            Rectangle()
                                                .fill(.gray.opacity(isCurrentTab ? 0.15 : 0.0))
                                                .overlay(alignment: .bottom) {
                                                    Rectangle()
                                                        .fill(isCurrentTab ? Color("AccentColor") : Color.clear)
                                                        .frame(height: 2)
                                                }
                                        }
                                }
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if let index = index { self.tabIndex = index }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 15)
                        
                        switch(tabIndex) {
                        case 0:
                            trickListViewByStance(
                                trickList: viewModel.regularTrickList,
                                trickListInfo: viewModel.trickListInfo,
                                stance: Stance.Stances.regular.rawValue,
                                userId: viewModel.user.userId
                            )
                            .environmentObject(viewModel)
                        case 1:
                            trickListViewByStance(
                                trickList: viewModel.fakieTrickList,
                                trickListInfo: viewModel.trickListInfo,
                                stance: Stance.Stances.fakie.rawValue,
                                userId: viewModel.user.userId
                            )
                            .environmentObject(viewModel)
                        case 2:
                            trickListViewByStance(
                                trickList: viewModel.switchTrickList,
                                trickListInfo: viewModel.trickListInfo,
                                stance: Stance.Stances._switch.rawValue,
                                userId: viewModel.user.userId
                            )
                            .environmentObject(viewModel)
                        case 3:
                            trickListViewByStance(
                                trickList: viewModel.nollieTrickList,
                                trickListInfo: viewModel.trickListInfo,
                                stance: Stance.Stances.nollie.rawValue,
                                userId: viewModel.user.userId
                            )
                            .environmentObject(viewModel)
                        default:
                            Text("No Tricks")
                        }
                    }
                }
                .alert("Error",
                       isPresented: Binding(
                        get: { viewModel.error != nil },
                        set: { _ in viewModel.error = nil }
                       )
                ) {
                    Button(role: .cancel) {
                        
                    } label: {
                        Text("OK")
                    }
                } message: {
                    Text(viewModel.error?.errorDescription ?? "afvaf")
                }
                    
            case .failure(let error):
                failedToFetchView(error)
            }
        }
    }
    
    func failedToFetchView(_ error: SPError) -> some View {
        VStack(alignment: .center) {
            Spacer()
            HStack { Spacer() }
            
            Text(error.errorDescription ?? "Error fetching tricks...")
                .padding()
                .multilineTextAlignment(.center)
            
            Button {
                Task {
                    // Re-fetches the users tricks and trick list info
                    await viewModel.loadTrickListView(userId: viewModel.user.userId)
                }
            } label: {
                Text("Try Again")
            }
            .foregroundColor(Color("buttonColor"))
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("buttonColor"))
            }
            
            Spacer()
        }
        .padding()
    }
}
