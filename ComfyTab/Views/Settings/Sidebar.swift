//
//  Sidebar.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct Sidebar: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        ScrollView {
            ForEach(SettingTab.allCases, id: \.self) { tab in
                Text(tab.rawValue)
                    .foregroundStyle(
                        tab.rawValue == self.viewModel.selectedTab.rawValue
                        ? Color.white
                        : Color.primary
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                tab.rawValue == self.viewModel.selectedTab.rawValue
                                ? .accentColor
                                : Color.clear
                            )
                    }
                    .onTapGesture {
                        viewModel.selectedTab = tab
                    }
            }
            .padding()
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
    }
}
