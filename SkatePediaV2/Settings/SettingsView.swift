//
//  SettingsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI
import FirebaseAuth

/// Defines the layout of items in the 'SettingsView'
struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
        
    @State private var toggleUpdatePassword: Bool = false
    @State private var toggleDeleteAccountVerifyer: Bool = false
    @State private var errorMessage: String = ""
    @State private var newPassword: String = ""
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            if let user = viewModel.user {
                
                List {
                    // Displays information about the user
                    Section(header: Text("Account Info").fontWeight(.bold)) {
                        HStack {
                            Text("Email:")
                            Spacer()
                            Text(String(describing: user.email))
                        }
                        HStack {
                            Text("Username:")
                            Spacer()
                            Text(String(describing: user.username))
                        }
                        HStack {
                            Text("Date Created:")
                            Spacer()
                            
                            Text(DateFormat.dateFormatter.string(from: user.dateCreated))
                        }
                    }
                    
                    Section(header: Text("Settings").fontWeight(.bold)) {
                        CustomNavLink(
                            destination: ProfileSettingsView(),
                            label: {
                            Text("Profile Settings")
                        })
                        CustomNavLink(
                            destination: TrickItemSettingsView(),
                            label: {
                            Text("Trick Item Settings")
                        })
                    }
                    
                    Section(header: Text("App Info").fontWeight(.bold)) {
                        CustomNavLink(
                            destination: AboutView(),
                            label: {
                            Text("About SkatePedia")
                        })
                        
//                        CustomNavLink(
//                            destination: TermsOfServiceView(),
//                            label: {
//                            Text("Terms of Service")
//                        })
                        
//                        CustomNavLink(
//                            destination: PrivacyPolicyView()
//                                .customNavBarItems(title: "Privacy Policy", subtitle: "", backButtonHidden: false)
//                            ,
//                            label: {
//                            Text("Trick Item Settings")
//                        })
                    }
                    
                    // Log out button
                    Section(header: Text("Log Out").fontWeight(.bold)) {
                        Button("Log out") {
                            Task {
                                do {
                                    try viewModel.signOut()
                                } catch {
                                    print("DEBUG: COULDNT SIGN OUT, \(error)")
                                }
                            }
                        }
                    }
                    .padding(3)
                    
                    Section(header: Text("Manage Account").fontWeight(.bold)) {
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        
                        Button("Update Password") {
                            toggleUpdatePassword.toggle()
                        }
                        .alert("Update Password", isPresented: $toggleUpdatePassword) {
                            updatePasswordPopupView
                        } message: {
                            Text("Enter new password.")
                        }
                        
                        Button(role: .destructive) {
                            toggleDeleteAccountVerifyer.toggle()
                        } label: {
                            Text("Delete Account")
                        }
                        .alert("Delete Account", isPresented: $toggleDeleteAccountVerifyer) {
                            verifyDeleteAccountPopup
                        } message: {
                            Text("Are you SURE you want to delete your account? All data and videos will be permenantly deleted...")
                        }
                    }
                }
            }  else {
                Text("Loading...")
            }
        }
    }
    
    @ViewBuilder
    var updatePasswordPopupView: some View {
        TextField("New Password", text: $newPassword)
            .autocorrectionDisabled()
            .autocapitalization(.none)
        
        Button("Cancel") {
            toggleUpdatePassword.toggle()
        }
        
        Button("Update") {
            Task {
                do {
                    try await viewModel.updatePassword(password: newPassword)
                    errorMessage = ""
                } catch {
                    print("DEBUG: PASSWORD NOT CHANGED, \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    @ViewBuilder
    var verifyDeleteAccountPopup: some View {
        Button("Delete", role: .destructive) {
            Task {
                do {
                    try await viewModel.deleteUser(userId: viewModel.user!.userId)
                } catch {
                    errorMessage = error.localizedDescription
                    print("DEBUG: COULDNT DELETE USER \(error.localizedDescription)")
                }
            }
        }
    }
    
}


//#Preview {
//    SettingsView(showSignInView: .constant(false))
//}
