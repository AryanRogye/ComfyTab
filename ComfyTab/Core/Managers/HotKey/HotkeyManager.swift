//
//  HotkeyManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import AppKit
import Combine

public class HotkeyManager {
    private(set) var permissionManager : PermissionManager
    private(set) var overlay           : Overlay
    private var modifierKeyMonitor     : ModifierComboMonitor?
    
    var cancellables = Set<AnyCancellable>()
    
    init(permissionManager: PermissionManager, overlay: Overlay) {
        self.permissionManager = permissionManager
        self.overlay           = overlay
        modifierKeyMonitor     = ModifierComboMonitor()
        
        overlay.overlayViewModel.$isPinned
            .sink { [weak self] isPinned in
                guard let self = self else { return }
                if !isPinned {
                    print("is Not Held Triggered")
                    /// We Wanna Check if Option is Being Held
                    /// if it is not then we wanna hide again
                    if let held = self.modifierKeyMonitor?.isOptionHeldGlobally() {	
                        if !held {
                            self.overlay.hide()
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func setupHotkey() {
        modifierKeyMonitor?.onOptionTabPressed = {
//            print("⌥ Tab Pressed")
            self.overlay.show()
        }
        
        modifierKeyMonitor?.onOptionReleased = {
            guard self.permissionManager.isAccessibilityEnabled else { return }
            guard !self.overlay.overlayViewModel.isPinned else { return }
//            print("⌥ Released")
            self.overlay.hide()
        }
    }
}
