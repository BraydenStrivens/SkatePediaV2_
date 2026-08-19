//
//  AccountDetailsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/25/26.
//

import SwiftUI
import FirebaseAuth

/// View that displays and allows editing of a user's account details.
///
/// Provides functionality to view and edit the user's:
/// - Profile photo
/// - Username
/// - Skateboarding stance
/// - Bio
///
/// Also displays read-only information such as email and account creation date.
///
/// Editing features:
/// - Users can change or delete their profile photo.
/// - Username, stance, and bio can be edited inline.
/// - Changes are saved through the `AccountOptionsViewModel`.
///
/// Toolbar buttons appear when any editable field is active, providing "Cancel" and "Save" actions.
///
/// - Parameters:
///   - user: The current user whose account details are displayed.
struct AccountDetails: View {
    @EnvironmentObject private var settingsVM: AccountOptionsViewModel
    
    @State private var showPhotoPicker: Bool = false
    @State private var editProfilePhoto: Bool = false
    @State private var editUsername: Bool = false
    @State private var editStance: Bool = false
    @State private var editBio: Bool = false
    
    func isEditting() -> Bool {
        return editProfilePhoto || editUsername || editStance || editBio
    }
    
    @FocusState private var usernameFocused: Bool
    @FocusState private var bioFocused: Bool
    
    let user: User
    
    var noChangesExist: Bool {
        user.username == settingsVM.newUsername &&
        user.stance == settingsVM.newStance &&
        user.bio == settingsVM.newBio &&
        settingsVM.profileImage == nil &&
        settingsVM.deleteProfilePhoto == false
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
        .contentShape(Rectangle())
        .onTapGesture {
            usernameFocused = false
            bioFocused = false
            cancelEdit()
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
    
    /// Displays the user's profile photo with options to change or delete.
    var profilePhoto: some View {
        VStack {
            Group {
                if let image = settingsVM.profileImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: ProfileImageSize.xxLarge.dimension,
                            height: ProfileImageSize.xxLarge.dimension
                        )
                        .clipShape(Circle())
                    
                } else {
                    if settingsVM.deleteProfilePhoto {
                        CircularProfileImageView(
                            photoUrl: nil,
                            size: .xxLarge
                        )
                    } else {
                        CircularProfileImageView(
                            photoUrl: user.profilePhoto?.photoUrl,
                            size: .xxLarge
                        )
                    }
                }
            }
            
            HStack(spacing: 14) {
                Button {
                    showPhotoPicker.toggle()
                    editProfilePhoto = true
                } label: {
                    Image(systemName: "camera")
                        .padding(10)
                        .foregroundColor(Color.button)
                        .background {
                            Circle()
                                .stroke(Color.button)
                                .fill(.ultraThinMaterial)
                        }
                }
                
                if user.profilePhoto != nil {
                    Button {
                        withAnimation(.smooth) {
                            settingsVM.deleteProfilePhoto = true
                            editProfilePhoto = true
                        }
                    } label: {
                        Image(systemName: "trash")
                            .padding(10)
                            .foregroundColor(.red)
                            .background {
                                Circle()
                                    .stroke(.red)
                                    .fill(.ultraThinMaterial)
                            }
                    }
                }
            }
        }
    }
    
    /// Displays and allows editing of the username.
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
                        .focused($usernameFocused)
                        .autocorrectionDisabled()
                        .onAppear { usernameFocused = true }
                }
            }
            .frame(maxWidth: 150, alignment: .trailing)
        }
    }
    
    /// Displays and allows editing of the user's skateboarding stance.
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
    
    /// Displays and allows editing of the user's bio.
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
                        .focused($bioFocused)
                        .autocorrectionDisabled()
                        .onAppear { bioFocused = true }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .border(Color(.systemGray5))
                }
            }
            .frame(maxWidth: 275, alignment: .trailing)
        }
    }
    
    /// Cancels all edits and resets the view model state.
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
