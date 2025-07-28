//
//  OverlayHome.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI

struct OverlayHome: View {
    var body: some View {
        VStack(spacing: 1) {
            HStack(alignment: .top) {
                
                WelcomeView()
                
                Divider()
                    .frame(maxHeight: .infinity)
                
                PastComfySessionView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }    
}
