//
//  TabbarItem.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import SwiftUI

struct TabBarItem: View {
    let defaultIcon: String
    let selectedIcon: String
    let index: Int
    let label: String
    @Binding var currentTab: Int
    
    var isSelected: Bool {
        index == currentTab
    }
    
    var body: some View {
        Button {
            currentTab = index

        } label: {
            VStack {
                Image(systemName: isSelected ? selectedIcon : defaultIcon)
                    .foregroundColor(isSelected ? Color.tabbarItem : .primary)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(isSelected ? Color.tabbarItem : .primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.tabbarItem : .clear)
                .frame(height: 2)
                .padding(.horizontal, 8)
        }
    }
}
