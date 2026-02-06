//
//  AuthenticationViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/4/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {

    @Published var userSession: FirebaseAuth.User?
    @Published private(set) var user: User?
    @Published var isLoading = true

    private let authService: AuthenticationService
    private var authHandle: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?

    init(authService: AuthenticationService = .shared) {
        self.authService = authService

        self.authHandle = authService.addAuthStateListener { [weak self] user in
            guard let self else { return }
            
            print("AUTH STATE CHANGE DETECTED")
            print("USER ID: ", user?.uid ?? "nil")
            print("===============================")
            self.user = nil
            self.userSession = user
            self.isLoading = false
            
            self.userListener?.remove()
            self.userListener = nil
            
            guard let uid = user?.uid else { return }
            

            Task {
//                await self.fetchUserDoc(userId: uid)
            }
            self.listenToUserDocument(userId: uid)
        }
    }

    deinit {
        if let handle = authHandle {
            authService.removeAuthStateListener(handle)
        }
        userListener?.remove()
    }
    
    func fetchUserDoc(userId: String) async {
        do {
            let dto = try await Firestore.firestore().collection("users").document(userId)
                .getDocument(as: UserDTO.self)
            self.user = try User(dto: dto)
            
        } catch let error as SPError {
            print("SPERROR FETCHING USER: ", mapToSPError(error: error))
        } catch {
            print("ERROR FETCHING USER: ", error)
        }
    }
    
    private func listenToUserDocument(userId: String) {
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        userListener = userRef.addSnapshotListener { [weak self] snapshot, error in
//            print("LISTENER FIRED: ", snapshot as Any)
//            print("SNAPSHOT EXISTS: ", snapshot?.exists ?? false)
            if let error = error {
                print("USER LISTENER ERROR: ", error.localizedDescription)
                return
            }
//            print("SETTINGS USER LISTENER")
            guard let self,
                  let snapshot,
                  snapshot.exists
            else {
                print("USER LISTENER SNAPSHOT NIL WITH NO ERROR")
                return
            }
            
            do {
//                print("SNAPSHOT DATA: ", snapshot.data())
//                let dto = try snapshot.data(as: UserDTO.self)
//                let newUser = try User(dto: dto)
                let newUser = try snapshot.data(as: User.self)
                
                // Avoids publishing the changes of noisy fields like 'unseen_notification_count'
                if
                    self.user?.bio != newUser.bio ||
                    self.user?.photoUrl != newUser.photoUrl ||
                    self.user?.settings != newUser.settings ||
                    self.user?.trickListData != newUser.trickListData
                {
                    print("USER SNAPSHOT RECIEVED")
                    self.user = newUser
                }
                
            } catch let error as SPError {
                print("USER DECODING FAILED: spError: ", error.errorDescription ?? "Something went wrong...")
            } catch {
                print("USER DECODING FAILED: ", error)
            }
            
                     
        }
    }
}
