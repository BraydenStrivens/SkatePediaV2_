//
//  TrickListViewByStance.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

struct trickListViewByStance: View {
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
                            TrickListCell(
                                userId: userId,
                                trick: easyTrick,
                                trickListInfo: trickListInfo
                            )
                        }
                    }
                    Section("Intermediate") {
                        ForEach(trickList[1]) { intermediateTrick in
                            TrickListCell(
                                userId: userId,
                                trick: intermediateTrick,
                                trickListInfo: trickListInfo
                            )
                        }
                    }
                    Section("Advanced") {
                        ForEach(trickList[2]) { advancedTrick in
                            TrickListCell(
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
                    .presentationDetents([.medium])
            })
        } else {
//            ProgressView()
//                .tint(.primary)
        }
    }
}
