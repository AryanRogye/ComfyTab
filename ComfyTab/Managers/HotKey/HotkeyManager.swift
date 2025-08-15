//
//  HotkeyManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import AppKit
import Combine

enum ModifierKey: UInt, CaseIterable, Identifiable {
    case option  = 524288     // NSEvent.ModifierFlags.option.rawValue
    case control = 262144     // NSEvent.ModifierFlags.control.rawValue
    case shift   = 131072     // NSEvent.ModifierFlags.shift.rawValue
    
    var id: Self { self }
    
    var flags: NSEvent.ModifierFlags {
        NSEvent.ModifierFlags(rawValue: rawValue)
    }
    
    var label: String {
        switch self {
        case .option:  return "Option"
        case .control: return "Control"
        case .shift:   return "Shift"
        }
    }
}


public class HotkeyManager {
    private(set) var permissionManager : PermissionManager
    private(set) var overlay           : Overlay
    private(set) var overlayViewModel  : OverlayViewModel
    private(set) var settingsManager   : SettingsManager
    private var modifierKeyMonitor     : ModifierComboMonitor?
    
    var cancellables = Set<AnyCancellable>()
    
    init(
        settingsManager: SettingsManager,
        permissionManager: PermissionManager,
        overlay: Overlay,
        overlayViewModel: OverlayViewModel
    ) {
        self.settingsManager   = settingsManager
        self.permissionManager = permissionManager
        self.overlay           = overlay
        self.overlayViewModel  = overlayViewModel
        modifierKeyMonitor     = ModifierComboMonitor(
            modifierKey: settingsManager.modifierKey
        )
        
        DispatchQueue.main.async {
            overlayViewModel.$isPinned
                .sink { [weak self] isPinned in
                    guard let self = self else { return }
                    if !isPinned {
                        print("is Not Held Triggered")
                        /// We Wanna Check if Option is Being Held
                        /// if it is not then we wanna hide again
                        if let held = self.modifierKeyMonitor?.isModifierPressedGlobally() {
                            if !held {
                                self.overlay.hide()
                            }
                        }
                    }
                }
                .store(in: &self.cancellables)
            
            /// Update Modifier Key with new Values if they change
            settingsManager.$modifierKey
                .sink { [weak self] modifier in
                    guard let self = self else { return }
                    self.modifierKeyMonitor?.modifierKey = modifier
                }
                .store(in: &self.cancellables)
        }
    }
    
    func setupHotkey() {
        modifierKeyMonitor?.onModifierPressed = {
            //            print("⌥ Tab Pressed")
            self.overlay.show()
        }
        
        self.modifierKeyMonitor?.onModifierReleased = {
            guard self.permissionManager.isAccessibilityEnabled else { return }
            guard !self.overlayViewModel.isPinned else { return }
            self.overlay.hide()
        }
    }
}
