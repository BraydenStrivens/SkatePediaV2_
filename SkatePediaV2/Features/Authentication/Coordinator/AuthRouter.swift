//
//  AuthRouter.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import Foundation
import SwiftUI

final class AuthRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func goToRegister() {
        path.append("register")
    }
    
    func goBack() {
        path.removeLast()
    }
}
