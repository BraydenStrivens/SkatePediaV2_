//
//  ErrorPopupStyle.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/4/26.
//

import Foundation

enum PopupStyle {
    case ok
    case autoDismiss(seconds: Double = 3)
    case retry(action: () async -> Void)
}
