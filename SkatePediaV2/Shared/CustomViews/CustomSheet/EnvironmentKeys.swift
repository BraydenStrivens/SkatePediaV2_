//
//  EnvironmentKeys.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/5/26.
//

import Foundation
import SwiftUI

private struct SPSheetDismissKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var spSheetDismiss: (() -> Void)? {
        get { self[SPSheetDismissKey.self] }
        set { self[SPSheetDismissKey.self] = newValue }
    }
}
