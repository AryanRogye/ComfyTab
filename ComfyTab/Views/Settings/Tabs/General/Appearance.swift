//
//  Appearance.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/16/25.
//

import SwiftUI

struct Appearance: View {
    
    @EnvironmentObject private var viewModel : GeneralViewModel
    
    var body: some View {
        Picker("App Theme", selection: viewModel.colorScheme) {
            ForEach(ColorSchemeSetting.allCases, id: \.self) { schema in
                Text(schema.rawValue)
                    .tag(schema)
            }
        }
    }
}
