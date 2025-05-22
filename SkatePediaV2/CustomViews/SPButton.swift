//
//  SPButton.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

enum ButtonRank {
    case primary
    case secondary
    case destructive
    case tertiary
}

struct CustomButtonStyle: ButtonStyle {
    let rank: ButtonRank
    let color: Color
    let width: CGFloat?
    let height: CGFloat?
    
    init(rank: ButtonRank, color: Color, width: CGFloat, height: CGFloat) {
        self.rank = rank
        self.width = width
        self.height = height
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(foregroundStyle)
            .frame(width: width, height: height)
            .background(background)
            .clipShape(.rect(cornerRadius: configuration.isPressed ? 20 : 10))
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .shadow(
                radius: rank == .primary || rank == .destructive ? 5 : 0,
                x: 0.0,
                y: rank == .primary || rank == .destructive ? 3 : 0)
            .overlay {
                if rank == .primary || rank == .destructive {
                    RoundedRectangle(cornerRadius: configuration.isPressed ? 20 : 10)
                        .stroke(background, lineWidth: 1.0)
                    
                } else if rank == .secondary {
                    RoundedRectangle(cornerRadius: configuration.isPressed ? 20 : 10)
                        .stroke(foregroundStyle, lineWidth: 1.0)
                }
            }
    }
    
    private var background: Color {
        switch rank {
        case .primary:
            return color
        case .destructive:
            return .red
        case .secondary:
            return Color(uiColor: UIColor.systemBackground)
        case .tertiary:
            return .clear
        }
    }
    
    private var foregroundStyle: Color {
        switch rank {
        case .primary, .destructive:
            return .white
        case .secondary, .tertiary:
            return color
        }
    }
}

extension ButtonStyle where Self == CustomButtonStyle {
    static func custom(rank: ButtonRank = .primary, color: Color = .blue, width: CGFloat = 360, height: CGFloat = 75) -> CustomButtonStyle {
        CustomButtonStyle(rank: rank, color: color, width: width, height: height)
    }
}


struct SPButton: View {
    let title: String
    let rank: ButtonRank
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void
    
    @State var isLoading = false
    
    var body: some View {
        Button {
            isLoading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
            action()
            
        } label: {
            if isLoading {
                ProgressView()
                    .tint(.primary)
            } else {
                Text(title)
            }
        }
        .buttonStyle(.custom(rank: rank, color: color, width: width, height: height))
    }
}

//#Preview {
//    SPButton(title: "Button", rank: .primary, width: 300, height: 50)
//    SPButton(title: "Button", rank: .secondary, width: 150, height: 100)
//    SPButton(title: "Button", rank: .tertiary, width: 125, height: 80)
//}


