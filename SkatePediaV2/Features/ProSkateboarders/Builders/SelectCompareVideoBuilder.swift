//
//  SelectCompareVideoBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/30/26.
//

import Foundation

/// Builds and configures the `SelectCompareVideoView` along with its dependencies.
///
/// This struct is responsible for creating the `SelectCompareVideoViewModel`
/// and injecting it into the `SelectCompareVideoView`.
@MainActor
struct SelectCompareVideoBuilder {
    
    /// Creates a fully configured `SelectCompareVideoView`.
    ///
    /// - Parameters:
    ///   - trickId: The identifier of the trick whose videos should be displayed.
    ///   - initialSelection: The currently selected comparison video, if any.
    ///   - defaultTab: The tab initially displayed when the selection view appears.
    ///   - onContinue: Closure executed when the user confirms a video selection.
    ///   - onCancel: Closure executed when the selection flow is canceled.
    ///   - appEnv: Class containing global stores and services.
    ///
    /// - Returns:
    /// A fully-configured `SelectCompareVideoView`.
    static func build(
        trickId: String,
        initialSelection: CompareVideo?,
        defaultTab: CompareVideoType,
        onContinue: @escaping (CompareVideo) -> Void,
        onCancel: @escaping () -> Void,
        appEnv: AppEnvironment
    ) -> SelectCompareVideoView {
        
        let viewModel = SelectCompareVideoViewModel(
            appEnv: appEnv
        )
        
        return SelectCompareVideoView(
            trickId: trickId,
            initialSelection: initialSelection,
            defaultTab: defaultTab,
            onContinue: onContinue,
            onCancel: onCancel,
            viewModel: viewModel
        )
    }
}
