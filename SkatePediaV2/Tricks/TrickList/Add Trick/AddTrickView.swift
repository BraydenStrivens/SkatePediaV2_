//
//  AddTrickView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/3/25.
//

import SwiftUI

struct AddTrickView: View {
    
    @StateObject var viewModel = AddTrickViewModel()
    
    let userId: String
    let stance: String
    let trickList: [[Trick]]
    let trickListInfo: TrickListInfo
    
    let difficulties: [String] = ["Easy", "Intermediate", "Advanced"]
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Spacer()
            
            VStack(alignment: .center, spacing: 15) {
                
                // Trick info user input
                TextField("Trick Name", text: $viewModel.trickName)
                    .autocorrectionDisabled()
                
                Divider()
                    .foregroundColor(.primary)
                
                TextField("Name Abbreviation", text: $viewModel.abbreviatedName)
                    .autocorrectionDisabled()
                
                Divider()
                    .foregroundColor(.primary)
                
                HStack {
                    Text("Difficulty:")
                    
                    Spacer()
                    
                    Menu(viewModel.difficulty, systemImage: "chevron.down") {
                        ForEach(difficulties, id: \.self) { difficulty in
                            Button {
                                viewModel.difficulty = difficulty
                            } label: {
                                Text(difficulty)
                            }
                        }
                    }
                }
                Divider()
                    .foregroundColor(.primary)
                
                selectLearnFirstSection
            }
            .customNavBarItems(title: "Add Trick", subtitle: "", backButtonHidden: false)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                    .fill(Color(uiColor: UIColor.systemBackground))
            }
            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 3)
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        Task {
                            try await viewModel.addTrickToList(userId: userId, stance: stance, trickListInfo: trickListInfo)
                            dismiss()
                        }
                    }
                    .opacity(viewModel.trickName.isEmpty || viewModel.learnFirst.isEmpty ? 0.3 : 1.0)
                    .disabled(viewModel.trickName.isEmpty || viewModel.learnFirst.isEmpty)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding()
                }
            }
            
            Spacer()
        }
    }
    
    var selectLearnFirstSection: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("Learn First:")
                
                Spacer()
                
                Menu("", systemImage: "plus.square") {
                    let trickNames: [String] = viewModel.getTrickNames(trickList: trickList)
                    
                    ForEach(trickNames, id: \.self) { name in
                        Button {
                            viewModel.learnFirst.append(name)
                        } label: {
                            Text(name)
                        }
                    }
                }
                
                Button {
                    let _ = viewModel.learnFirst.popLast()
                } label: {
                    Image(systemName: "delete.backward")
                }
            }
            
            Text(viewModel.convertArrayToString(array: viewModel.learnFirst))
                .frame(height: 20)
                .foregroundColor(.blue)
                .font(.caption)
                .lineLimit(nil)
                .multilineTextAlignment(.trailing)
            
            
        }
    }
}

//#Preview {
//    AddTrickView()
//}
