//
//  ReportPopup.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/24/26.
//

import SwiftUI

struct ReportItemSheet: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.spSheetDismiss) private var dismissSheet
    
    @FocusState private var textFieldFocuses: Bool
    
    @StateObject var viewModel: ReportItemSheetViewModel
    let currentUid: String
    let otherUid: String
    
    init(
        currentUid: String,
        otherUid: String,
        viewModel: ReportItemSheetViewModel
    ) {
        self.currentUid = currentUid
        self.otherUid = otherUid
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 25) {
                Text(popupTitle())
                    .font(.title2).fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                if !viewModel.successMessage.isEmpty {
                    Text(viewModel.successMessage)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.button)
                        .padding(.horizontal)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(ReportReason.allCases) { reason in
                            reportReasonCell(reason)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                TextField(
                    "Additional Information",
                    text: $viewModel.additionContext,
                    axis: .vertical
                )
                .autocorrectionDisabled()
                .padding(10)
                .lineLimit(1...5)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(textFieldFocuses ? Color.button : .gray)
                }
                .tint(Color.button)
                .padding(.horizontal)
                .focused($textFieldFocuses)
                
                actionButtons
                    .padding(.horizontal)
            }
            .ignoresSafeArea(.keyboard)
            .padding(.vertical)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
            .frame(maxWidth: UIScreen.screenWidth * 0.8, maxHeight: UIScreen.screenHeight * 0.6)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            textFieldFocuses = false
        }
    }
    
    private var actionButtons: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    dismissSheet?()
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.primary)
                }
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.report(
                            currentUid: currentUid,
                            otherUid: otherUid
                        )
                        
                        if !viewModel.successMessage.isEmpty {
                            dismissSheet?()
                        }
                    }
                } label: {
                    if viewModel.reportLoading {
                        ProgressView()
                    } else {
                        Text("Report")
                    }
                }
                .disabled(viewModel.reportLoading)
                .disabled(viewModel.blockAndReportLoading)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.button)
                }
            }
            
            Button {
                Task {
                    await viewModel.reportAndBlock(
                        currentUid: currentUid,
                        otherUid: otherUid
                    )
                    
                    if !viewModel.successMessage.isEmpty {
                        dismissSheet?()
                    }
                }
            } label: {
                if viewModel.blockAndReportLoading {
                    ProgressView()
                } else {
                    Text("Block and Report")
                }
            }
            .disabled(viewModel.blockAndReportLoading)
            .disabled(viewModel.reportLoading)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.red)
            }
        }
    }
    
    private func reportReasonCell(_ reason: ReportReason) -> some View {
        HStack {
            Circle()
                .stroke(.primary)
                .fill(reason == viewModel.reportReason ? Color.button : Color.clear)
                .frame(width: 12, height: 12)
            
            Text(reason.displayString)
                .font(.footnote)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.smooth(duration: 0.15)) {
                viewModel.reportReason = reason
            }
        }
    }
    
    private func popupTitle() -> String {
        switch viewModel.reportType {
        case .post:
            "Report Post"
        case .comment:
            "Report Comment"
        case .profile:
            "Report Profile"
        }
    }
}
