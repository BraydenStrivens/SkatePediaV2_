//
//  TabbarItem.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import SwiftUI

/// A reusable tab bar item used within the app's custom tab bar.
///
/// `TabBarItem` displays:
/// - A tab icon
/// - A tab label
/// - A visual selected-state indicator
///
/// The item updates the currently selected tab when tapped and
/// visually reflects whether it is the active tab.
struct TabBarItem: View {
    
    // MARK: Parameters
    
    let defaultIcon: String
    let selectedIcon: String
    let tab: Tab
    let label: String
    @Binding var currentTab: Tab
    
    // MARK: Derived/Private Properties
    
    private var isSelected: Bool {
        tab == currentTab
    }
    
    // MARK: Body
    var body: some View {
        Button {
            currentTab = tab

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
