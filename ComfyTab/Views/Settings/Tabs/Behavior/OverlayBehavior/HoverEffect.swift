//
//  HoverEffect.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/17/25.
//

import SwiftUI

struct HoverEffect: View {
    
    @EnvironmentObject var viewModel: BehaviorViewModel

    var body: some View {
        HStack {
            Text("Hover Effect")
            
            Spacer()
            
            Toggle("Hover Effect", isOn: viewModel.isHoverEffectEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }
}
