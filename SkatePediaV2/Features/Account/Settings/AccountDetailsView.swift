//
//  AccountDetailsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/25/26.
//

import SwiftUI
import FirebaseAuth

struct AccountDetailsView: View {
    @EnvironmentObject private var settingsVM: SettingsViewModel
    
    @State private var showPhotoPicker: Bool = false
    @State private var editProfilePhoto: Bool = false
    @State private var editUsername: Bool = false
    @State private var editStance: Bool = false
    @State private var editBio: Bool = false
    
    func isEditting() -> Bool {
        return editProfilePhoto || editUsername || editStance || editBio
    }
    
    @FocusState private var usernameTextFieldFocused: Bool
    @FocusState private var bioTextFieldFocused: Bool
    
    let user: User
    
    var noChangesExist: Bool {
        user.username == settingsVM.newUsername &&
        user.stance == settingsVM.newStance &&
        user.bio == settingsVM.newBio &&
        settingsVM.profileImage == nil
    }
    
    var body: some View {
        VStack {
            profilePhoto
            Divider()
            
            username
            Divider()
            
            stance
            Divider()
            
            bio
            Divider()
            
            HStack {
                Text("Email:")
                Spacer()
                Text(Auth.auth().currentUser?.email ?? "")
            }
            
            Divider()
            
            HStack {
                Text("Date Created:")
                Spacer()
                
                Text(user.dateCreated.formatted(date: .long, time: .omitted))
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $settingsVM.selectedItem,
            matching: .images
        )
        .toolbar {
            if isEditting() {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        cancelEdit()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            let success = await settingsVM.updateUserProfile()
                            
                            if success { cancelEdit() }
                        }
                    } label: {
                        if settingsVM.updatingUser {
                            ProgressView()
                        } else {
                            Text("Save")
                                .foregroundStyle(Color.button)
                        }
                    }
                    .disabled(noChangesExist)
                }
            }
        }
    }
    
    var profilePhoto: some View {
        HStack {
            Group {
                if let image = settingsVM.profileImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())
                    
                } else {
                    if settingsVM.deleteProfilePhoto {
                        CircularProfileImageView(
                            photoUrl: nil,
                            size: .xLarge
                        )
                    } else {
                        CircularProfileImageView(
                            photoUrl: user.profilePhoto?.photoUrl,
                            size: .xLarge
                        )
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button("Change") {
                    showPhotoPicker.toggle()
                    editProfilePhoto.toggle()
                }
                .tint(Color.button)
                
                if user.profilePhoto != nil {
                    Button("Delete", role: .destructive) {
                        withAnimation(.smooth) {
                            settingsVM.deleteProfilePhoto = true
                            editProfilePhoto.toggle()
                        }
                    }
                }
            }
            .font(.caption)
        }
    }
    
    var username: some View {
        HStack {
            Text("Username:")
            Button {
                withAnimation(.smooth) {
                    editUsername.toggle()
                }
            } label: {
                Image(systemName: "pencil")
                    .opacity(editUsername ? 0.35 : 1)
            }
            Spacer()
            
            Group {
                if !editUsername {
                    Text(user.username)
                    
                } else {
                    TextField("", text: $settingsVM.newUsername)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .border(Color(.systemGray5))
                        .focused($usernameTextFieldFocused)
                        .autocorrectionDisabled()
                        .onAppear { usernameTextFieldFocused = true }
                }
            }
            .frame(maxWidth: 150, alignment: .trailing)
        }
    }
    
    var stance: some View {
        HStack {
            Text("Stance:")
            Button {
                withAnimation(.smooth) {
                    editStance.toggle()
                }
            } label: {
                Image(systemName: "pencil")
                    .opacity(editStance ? 0.35 : 1)
            }
            Spacer()
            
            Group {
                if editStance {
                    HStack {
                        ForEach(UserStance.allCases) { userStance in
                            let isCurrent = userStance == settingsVM.newStance
                            Button {
                                settingsVM.newStance = userStance
                            } label: {
                                Text(userStance.camalCase)
                                    .foregroundColor(isCurrent ? .primary : .gray)
                                    .fontWeight(isCurrent ? .semibold : .regular)
                                
                            }
                        }
                    }
                } else {
                    Text(user.stance.camalCase)
                }
            }
        }
    }
    
    var bio: some View {
        HStack(alignment: .top) {
            Text("Bio:")
            Button {
                withAnimation(.smooth) {
                    editBio.toggle()
                }
            } label: {
                Image(systemName: "pencil")
                    .opacity(editBio ? 0.35 : 1)
            }
            Spacer()
            
            Group {
                if !editBio {
                    if !user.bio.isEmpty {
                        CollapsibleTextView(text: user.bio, lineLimit: 4, font: .body)
                    }
                    
                } else {
                    TextField("", text: $settingsVM.newBio, axis: .vertical)
                        .lineLimit(1...8)
                        .focused($bioTextFieldFocused)
                        .autocorrectionDisabled()
                        .onAppear { bioTextFieldFocused = true }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .border(Color(.systemGray5))
                }
            }
            .frame(maxWidth: 275, alignment: .trailing)
        }
    }
    
    func cancelEdit() {
        withAnimation(.smooth) {
            self.editProfilePhoto = false
            self.editUsername = false
            self.editStance = false
            self.editBio = false
            settingsVM.resetEdit()
        }
    }
}
