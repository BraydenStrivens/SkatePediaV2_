//
//  SPAlertPopup.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/2/26.
//

import SwiftUI

class SPAlertManager: ObservableObject {
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    func triggerAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct SPAlertPopup: View {
    @StateObject private var alertManager = SPAlertManager()
    
    var body: some View {
        VStack {
            
        }
    }
}

#Preview {
    SPAlertPopup()
}
