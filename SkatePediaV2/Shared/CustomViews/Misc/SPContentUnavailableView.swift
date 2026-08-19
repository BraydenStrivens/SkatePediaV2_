//
//  SPContentUnavailableView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/21/26.
//

import SwiftUI

enum ContentUnavailableType {
    case blockingError
    case emptyList
    case noImage
}

struct SPContentUnavailableView: View {
    let title: String
    let description: String?
    let type: ContentUnavailableType
    
    init(
        title: String,
        description: String? = nil,
        type: ContentUnavailableType = .noImage
    ) {
        self.title = title
        self.description = description
        self.type = type
    }
    
    var body: some View {
        if let description {
            switch type {
            case .blockingError:
                ContentUnavailableView(
                    title,
                    systemImage: "exclamationmark.triangle",
                    description: Text(description)
                )
                
            case .emptyList:
                ContentUnavailableView(
                    title,
                    systemImage: "list.bullet.rectangle.portrait",
                    description: Text(description)
                )
                
            case .noImage:
                ContentUnavailableView {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(description)
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
            
        } else {
            switch type {
            case .blockingError:
                ContentUnavailableView(
                    title,
                    systemImage: "exclamationmark.triangle"
                )
                
            case .emptyList:
                ContentUnavailableView(
                    title,
                    systemImage: "list.bullet.rectangle.portrait"
                )
                
            case .noImage:
                ContentUnavailableView {
                    Text(title)
                        .font(.title3).fontWeight(.bold)
                }
            }
        }
    }
}
