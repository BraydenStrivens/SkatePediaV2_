//
//  CreateSpinnerViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/9/26.
//

import Foundation

final class CreateSpinnerViewModel: ObservableObject {
    @Published private(set) var tricks: [Trick]
    
    init(tricks: [Trick]) {
        self.tricks = tricks 
    }
}
