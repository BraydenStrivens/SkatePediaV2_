//
//  TrickListViewByStance.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

struct trickListViewByStance: View {
    @EnvironmentObject var trickListViewModel: TrickListViewModel
    
    let trickList: [[Trick]]
    let trickListInfo: TrickListInfo
    let stance: String
    let userId: String
    
    @State private var showAddTrickView = false
    
    var body: some View {
        if !trickList.isEmpty{
            VStack {
                // Displays total tricks learned by stance
                trickListInfoView(stance: stance, trickListInfo: trickListInfo)
                
                // Add trick button
                HStack(alignment: .center) {
                    Spacer()
                    
                    Button {
                        showAddTrickView.toggle()
                    } label: {
                        Text("Add Trick")
                            .foregroundColor(.primary)
                        Image(systemName: "plus.square")
                            .tint(Color("buttonColor"))
                    }
                    .padding()
                }
                
                // Trick list separated by difficulty
                List {
                    Section("Easy") {
                        ForEach(trickList[0]) { easyTrick in
                            trickListCell(
                                userId: userId,
                                trick: easyTrick,
                                trickListInfo: trickListInfo
                            )
                        }
                    }
                    Section("Intermediate") {
                        ForEach(trickList[1]) { intermediateTrick in
                            trickListCell(
                                userId: userId,
                                trick: intermediateTrick,
                                trickListInfo: trickListInfo
                            )
                        }
                    }
                    Section("Advanced") {
                        ForEach(trickList[2]) { advancedTrick in
                            trickListCell(
                                userId: userId,
                                trick: advancedTrick,
                                trickListInfo: trickListInfo
                            )
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddTrickView, onDismiss: {
                showAddTrickView = false
            }, content: {
                AddTrickView(userId: userId, stance: stance, trickList: trickList, trickListInfo: trickListInfo)
                    .presentationDetents([.height(350)])
                    .environmentObject(trickListViewModel)
            })
        } else {
            ContentUnavailableView(
                "No Tricks Found",
                systemImage: "exclamationmark.triangle",
                description: Text("Failed to fetch \(stance) tricks...")
            )
        }
    }
    
    func trickListCell(userId: String, trick: Trick, trickListInfo: TrickListInfo) -> some View {
        CustomNavLink(
            destination: TrickView(userId: userId, trick: trick)
                .customNavBarItems(title: trick.name, subtitle: "", backButtonHidden: false)
        ) {
            HStack(alignment: .center, spacing: 12) {
                Text(trick.name)
                    .foregroundColor(.primary)
                    .font(.callout)
                
                Spacer()
                
                if trick.progress.isEmpty {
                    Image(systemName: "circle")
                        .resizable()
                        .foregroundColor(Color("buttonColor"))
                        .frame(width: 20, height: 20)
                } else {
                    let maxRating = trick.progress.max()!
                    
                    if maxRating == 0 {
                        Image(systemName: "circle")
                            .resizable()
                            .foregroundColor(Color("buttonColor"))
                            .frame(width: 20, height: 20)
                    } else if maxRating == 1 {
                        Image(systemName: "circle.circle")
                            .resizable()
                            .foregroundColor(Color("buttonColor"))
                            .frame(width: 20, height: 20)
                    } else if maxRating == 2 {
                        Image(systemName: "circle.circle.fill")
                            .resizable()
                            .foregroundColor(Color("buttonColor"))
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .foregroundColor(Color("AccentColor"))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .contextMenu {
                Button("Delete From List", role: .destructive) {
                    Task {
                        try await TrickListManager.shared.deleteTrick(
                            userId: userId,
                            trick: trick
                            )
                    }
                }
            }
        }
    }
}
