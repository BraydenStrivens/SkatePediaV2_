//
//  NewMessageCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/25.
//

import SwiftUI

struct NewMessageCell: View {
    enum UserChatExistsFetchState {
        case loading
        case exists(UserChat)
        case doesNotExist
        case failure(SPError)
    }
    
    @EnvironmentObject var errorStore: ErrorStore
    
    let currentUser: User
    let withUser: User
    let existingUserChat: () async throws -> UserChat?
    @State var fetchState: UserChatExistsFetchState = .loading
    
    var body: some View {
        Group {
            switch fetchState {
            case .loading:
                CustomProgressView(placement: .center)
                
            case .exists(let userChat):
                NavigationLink(
                    destination: ChatMessagesViewContainer(
                        currentUser: currentUser,
                        withUserData: UserData(user: withUser),
                        userChat: userChat,
                        errorStore: errorStore
                    )
                ) {
                    userPreviewCell
                }
                
            case .doesNotExist:
                NavigationLink(
                    destination: ChatMessagesViewContainer(
                        currentUser: currentUser,
                        withUserData: UserData(user: withUser),
                        errorStore: errorStore
                    )
                ) {
                    userPreviewCell
                }
                
            case .failure(let firestoreError):
                VStack {
                    Text(firestoreError.errorDescription ?? "Error...")
                        .foregroundStyle(.gray)
                }
            }
        }
        .task {
            do {
                self.fetchState = .loading
                
                if let userChat = try await existingUserChat() {
                    self.fetchState = .exists(userChat)
                } else {
                    self.fetchState = .doesNotExist
                }
                
            } catch let error as FirestoreError {
                self.fetchState = .failure(.firestore(error))
            } catch {
                self.fetchState = .failure(.unknown)
            }
        }
    }
    
    var userPreviewCell: some View {
        HStack(alignment: .top, spacing: 10) {
            CircularProfileImageView(photoUrl: withUser.profilePhoto?.photoUrl, size: .large)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("@\(withUser.username)")
                    .font(.title3)
                Text(withUser.stance.camalCase)
                    .font(.footnote)
            }
            .foregroundColor(.primary)
            
            Spacer()
        }
    }
}
