//
//  OverlayViewModel.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import Combine

class OverlayViewModel: ObservableObject {
    @Published var isPinned: Bool = false
    
    public func togglePinned() {
        isPinned.toggle()
        
        if isPinned {
            
        } else {
            
        }
    }
}
