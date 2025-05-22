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
    @State private var tabIndex = 0
    
    var body: some View {
        VStack {
            // Displays total tricks learned bar
            trickListInfoView(stance: "", trickListInfo: viewModel.trickListInfo)
            
            // Sections for each stance
            SlidingTabView(
                selection: $tabIndex,
                tabs: ["Regular", "Fakie", "Switch", "Nollie"],
                animation: .easeInOut,
                activeAccentColor: .blue,
                activeTabColor: .gray.opacity(0.2)
            )
            .foregroundColor(.primary)
            .padding()
            
            Spacer()
            
            // Displays trick list for each stance
            if let user = viewModel.user, let info = viewModel.trickListInfo, viewModel.fetched == true {
                switch(tabIndex) {
                case 0:

                    if !viewModel.regularTrickList[0].isEmpty {
                        trickListViewByStance(
                            trickList: viewModel.regularTrickList,
                            trickListInfo: info,
                            stance: Stance.Stances.regular.rawValue,
                            userId: user.userId
                        )
                    } else {
                        failedToFetchView
                    }
                    
                case 1:
                    if !viewModel.fakieTrickList[0].isEmpty {
                        trickListViewByStance(
                            trickList: viewModel.fakieTrickList,
                            trickListInfo: info,
                            stance: Stance.Stances.fakie.rawValue,
                            userId: user.userId
                        )
                    } else {
                        failedToFetchView
                    }
                    
                case 2:
                    if !viewModel.switchTrickList[0].isEmpty {
                        trickListViewByStance(
                            trickList: viewModel.switchTrickList,
                            trickListInfo: info,
                            stance: Stance.Stances._switch.rawValue,
                            userId: user.userId
                        )
                    } else {
                        failedToFetchView
                    }
                    
                case 3:
                    if !viewModel.nollieTrickList[0].isEmpty {
                        trickListViewByStance(
                            trickList: viewModel.nollieTrickList,
                            trickListInfo: info,
                            stance: Stance.Stances.nollie.rawValue,
                            userId: user.userId
                        )
                    } else {
                        failedToFetchView
                    }
                    
                default:
                    Text("No Stance Selected")
                }
            } else {
                if viewModel.failedToFetch {
                    failedToFetchView
                } else {
                    CustomProgressView(placement: .center)
                }
            }
        }
    }
    
    var failedToFetchView: some View {
        VStack(alignment: .center) {
            Spacer()
            
            HStack {
                Spacer()
            }
            
            Text("Failed to fetch trick list...")

            Button {
                Task {
                    try await TrickListManager.shared.readJSonFile(userId: "")
                }
            } label: {
                Text("Regenerate Trick List")
            }
            .foregroundColor(.blue)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.blue)
            }
            
            Spacer()
        }
    }
}
