//
//  CollapsibleTextView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

struct CollapsibleTextView: View {
    let text: String
    let lineLimit: Int
    let font: Font
    
    @State private var expanded = false
    @State private var truncated = false
    @State private var truncatedText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                if truncated && !expanded {
                    (
                        Text(truncatedText)
                        + Text("... ")
                        + Text("More")
                            .foregroundStyle(Color.accent)
                            .font(font)
                    )
                } else {
                    (
                        Text(text)
                        + (truncated ?
                           Text("  ")
                           + Text("Less")
                            .foregroundStyle(Color.accent)
                           : Text("")
                          )
                    )
                }
            }
            .font(font)
            .lineLimit(expanded ? nil : lineLimit)
            .background(
                TextMeasurementView(
                    text: text,
                    lineLimit: lineLimit,
                    font: font,
                    truncated: $truncated,
                    truncatedText: $truncatedText
                )
            )
            .onTapGesture {
                if truncated {
                    withAnimation(.easeInOut) {
                        expanded.toggle()
                    }
                }
            }
        }
    }
}

private struct TextMeasurementView: View {
    let text: String
    let lineLimit: Int
    let font: Font
    
    @Binding var truncated: Bool
    @Binding var truncatedText: String
    
    var body: some View {
        GeometryReader { geometry in
            Text(text)
                .font(font)
                .lineLimit(lineLimit)
                .background(
                    Text(text)
                        .font(font)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .background(
                            GeometryReader { fullSize in
                                Color.clear.onAppear {
                                    checkTruncation(
                                        containerWidth: geometry.size.width,
                                        fullHeight: fullSize.size.height
                                    )
                                }
                            }
                        )
                )
                .hidden()
        }
    }
    
    private func checkTruncation(containerWidth: CGFloat, fullHeight: CGFloat) {
        let uiFont = UIFont.preferredFont(from: font)
        let maxHeight = uiFont.lineHeight * CGFloat(lineLimit)
        
        DispatchQueue.main.async {
            truncated = fullHeight > maxHeight
            
            if truncated {
                truncatedText = computeTruncatedText(
                    containerWidth: containerWidth,
                    uiFont: uiFont
                )
            }
        }
    }
    
    private func computeTruncatedText(containerWidth: CGFloat, uiFont: UIFont) -> String {
        var truncatedString = text
        
        while truncatedString.count > 0 {
            let boundingRect = (truncatedString + "... Show More")
                .boundingRect(
                    with: CGSize(width: containerWidth, height: .greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    attributes: [.font: uiFont],
                    context: nil
                )
            
            if boundingRect.height <= uiFont.lineHeight * CGFloat(lineLimit) {
                break
            }
            
            truncatedString.removeLast()
        }
        
        return truncatedString
    }
}

private extension UIFont {
    static func preferredFont(from font: Font) -> UIFont {
        switch font {
        case .caption:
            return UIFont.preferredFont(forTextStyle: .caption1)
        case .headline:
            return UIFont.preferredFont(forTextStyle: .headline)
        default:
            return UIFont.preferredFont(forTextStyle: .body)
        }
    }
}
