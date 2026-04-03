//
//  Tabbar.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import Foundation
import SwiftUI

/// Defines a custom environment key to store the height of the app's tab bar.
private struct TabbarHeightKey: EnvironmentKey {
    /// Default tab bar height is 0.
    static let defaultValue: CGFloat = 0
}

/// Provides convenient access to the `tabbarHeight` environment value.
extension EnvironmentValues {
    var tabbarHeight: CGFloat {
        get { self[TabbarHeightKey.self] }
        set { self[TabbarHeightKey.self] = newValue }
    }
}



