//
//  CustomPreferenceKeys.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/6/26.
//

import Foundation
import SwiftUI

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct FrameSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = CGSize(width: 0, height: 0)
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
