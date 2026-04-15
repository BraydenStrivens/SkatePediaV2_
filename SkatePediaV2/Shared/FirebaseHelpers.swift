//
//  FirebaseHelpers.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/13/26.
//

import Foundation
import FirebaseFirestore

final class FirebaseHelpers {
    static func generateFirebaseId() -> String {
        return Firestore.firestore().collection("not_a_real_collection").document().documentID
    }
}
