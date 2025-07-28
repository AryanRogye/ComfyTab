//
//  OverlayViewModel.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import Combine

enum OverlayState {
    case homeView
    case configureVibe
    case goWithFlow
}

class OverlayViewModel: ObservableObject {
    @Published var isPinned: Bool = false
    
    var lastState: OverlayState? = nil
    @Published var overlayState : OverlayState = .homeView
    
    init(overlayState: OverlayState = .homeView) {
        self.overlayState = overlayState
    }
    
    public func togglePinned() {
        isPinned.toggle()
    }
    
    public func switchOverlayState(to state: OverlayState) {
        self.lastState = self.overlayState
        self.overlayState = state
        
        if overlayState == .homeView {
            self.lastState = nil
        }
    }
    
    public func goBack() {
        guard let lastState = lastState else { return }
        self.overlayState = lastState
        self.lastState = nil
    }
}
