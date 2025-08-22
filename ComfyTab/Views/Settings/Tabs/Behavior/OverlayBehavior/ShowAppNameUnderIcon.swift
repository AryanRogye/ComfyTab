//
//  ShowAppNameUnderIcon.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/17/25.
//

import SwiftUI

struct ShowAppNameUnderIcon: View {
    
    @EnvironmentObject var viewModel: BehaviorViewModel

    var body: some View {
        HStack {
            Text("Show App Name Under Icon")
            
            Spacer()
            
            Toggle("Show App Name Under Icon", isOn: viewModel.showAppNameUnderIcon)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }
}
