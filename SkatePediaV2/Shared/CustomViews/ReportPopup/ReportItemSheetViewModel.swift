//
//  ReportPopupViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/24/26.
//

import Foundation

@MainActor
final class ReportItemSheetViewModel: ObservableObject {
    
    @Published var reportLoading: Bool = false
    @Published var blockAndReportLoading: Bool = false
    @Published var successMessage: String = ""
    
    @Published var reportType: ReportType
    @Published var reportReason: ReportReason = .spam
    @Published var additionContext: String = ""
    
    private let appEnv: AppEnvironment
    private let errorStore: ErrorStore
    
    init(
        reportType: ReportType,
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) {
        self.reportType = reportType
        self.appEnv = appEnv
        self.errorStore = errorStore
    }
    
    func report(
        currentUid: String,
        otherUid: String
    ) async {
        reportLoading = true
        defer { reportLoading = false }
        
        do {
            switch reportType {
            case .post(let post):
                try await appEnv.postService.reportPost(
                    otherUid: otherUid,
                    post: post,
                    reportReason: reportReason,
                    additionalContext: additionContext.isEmpty ? nil : additionContext
                )
                successMessage = "Post successfully reported."
                
            case .comment(let comment):
                try await appEnv.commentService.reportComment(
                    otherUid: otherUid,
                    comment: comment,
                    reportReason: reportReason,
                    additionalContext: additionContext.isEmpty ? nil : additionContext
                )
                successMessage = "Comment successfully reported."

            case .profile:
                try await appEnv.relationshipService.reportUser(
                    otherUid: otherUid,
                    reportReason: reportReason,
                    additionalContext: additionContext.isEmpty ? nil : additionContext
                )
                successMessage = "User successfully reported."
            }
            
            try? await Task.sleep(for: .milliseconds(1000))
            
        } catch {
            errorStore.present(error, title: "Error Creating Report")
        }
    }
    
    func reportAndBlock(
        currentUid: String,
        otherUid: String
    ) async {
        blockAndReportLoading = true
        defer { blockAndReportLoading = false }
        
        do {
            try await appEnv.relationshipService.blockAndReportUser(
                currentUid: currentUid,
                otherUid: otherUid,
                reportReason: reportReason,
                additionalContext: additionContext.isEmpty ? nil : additionContext
            )
            successMessage = "User successfully blocked and reported."
            try? await Task.sleep(for: .milliseconds(1000))
            
        } catch {
            errorStore.present(error, title: "Error Blocking and Reporting User")
        }
    }
}
