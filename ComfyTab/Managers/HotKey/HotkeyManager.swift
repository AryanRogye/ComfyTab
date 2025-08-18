//
//  HotkeyManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import AppKit
import Combine
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleTab = Self("ComfyTabToggleTab")
}

public class HotkeyManager {
    
    private(set) var overlay           : Overlay
    private(set) var overlayViewModel  : OverlayViewModel
    private(set) var settingsManager   : SettingsManager
    private(set) var localMonitor      = LocalMonitor()
    private(set) var toggleTabHotKey   : KeyboardShortcuts.Name

    var cancellables = Set<AnyCancellable>()
    
    init(
        settingsManager     : SettingsManager,
        overlay             : Overlay,
        overlayViewModel    : OverlayViewModel,
        toggleTabHotKey     : KeyboardShortcuts.Name = .toggleTab
    ) {
        self.settingsManager   = settingsManager
        self.overlay           = overlay
        self.overlayViewModel  = overlayViewModel
        self.toggleTabHotKey   = toggleTabHotKey
        
        prepareHotKey()
        /// We Bind For The Pinning Logic, Currently Unused
        
        /// From Mermaid Diagram This is the setupPinningListener()
        DispatchQueue.main.async {
            overlayViewModel.$isPinned
                .sink { [weak self] isPinned in
                    guard let self = self else { return }
                    if !isPinned {
                        print("is Not Held Triggered")
                        /// We Wanna Check if Option is Being Held
                        /// if it is not then we wanna hide again
                        if !self.localMonitor.isHeldNow() {
                            self.overlay.hide()
                        }
                    }
                }
                .store(in: &self.cancellables)
            
            /// Update Modifier Key with new Values if they change
            /// From Mermaid Diagram This is the setupHotKeyChangeListener()
            settingsManager.$modifierKey
                .sink { modifier in
                    /// Only Allowed is control,option and shift, so only those are set
                    KeyboardShortcuts.setShortcut(
                        .init(.tab, modifiers: [
                            modifier == .control ? .control
                                : modifier == .option ? .option
                                    : .shift
                        ]),
                        for: .toggleTab
                    )
                }
                .store(in: &self.cancellables)
        }
    }
    
    private func prepareHotKey() {
        /// We Load in what the modifier key is in at the start
        KeyboardShortcuts.setShortcut(
            .init(.tab, modifiers: [
                settingsManager.modifierKey == .control ? .control
                : settingsManager.modifierKey == .option ? .option
                : .shift
            ]),
            for: .toggleTab
        )
    }
    
    /// This Works Pretty Nicely:
    /// On KeyDown Meaning: Modifier Key: [option, shift, or control] and `Tab` we trigger our overlay, but in that time
    /// we can let go of  tab, but we want `modifier` to still count as being held, so we start a local monitor to take over
    /// and so now, we can let the modifier be the "keyBind" that the on release will stop it
    func setupHotkey() {
        KeyboardShortcuts.onKeyDown(for: self.toggleTabHotKey) {
            self.localMonitor.start(with: self.settingsManager.modifierKey) { self.onEnd() }
            self.overlay.show()
        }
    }
    
    private func onEnd() {
        /// If Pinned Dont Hide
        guard !self.overlayViewModel.isPinned else {
            return
        }
        /// Hide Overlay
        self.overlay.hide()
    }
}
