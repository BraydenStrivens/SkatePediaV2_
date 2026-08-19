//
//  ReportPopupBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/24/26.
//

import Foundation
import SwiftUI

struct ReportItemSheetBuilder {
    
    @MainActor
    static func build(
        currentUid: String,
        otherUid: String,
        reportType: ReportType,
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) -> ReportItemSheet {
        
        let viewModel = ReportItemSheetViewModel(
            reportType: reportType,
            appEnv: appEnv,
            errorStore: errorStore
        )
        
        return ReportItemSheet(
            currentUid: currentUid,
            otherUid: otherUid,
            viewModel: viewModel
        )
    }
}
