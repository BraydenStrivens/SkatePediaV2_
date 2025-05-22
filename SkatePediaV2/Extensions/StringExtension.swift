//
//  StringExtension.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation

extension String {
    subscript(_ index: Int) -> Character? {
        guard index >= 0, index < self.count else { return nil }
        
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
