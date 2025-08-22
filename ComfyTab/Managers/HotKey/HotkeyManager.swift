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

@MainActor
public class HotkeyManager {
    
    private(set) var settingsService   : SettingsService
    private(set) var localMonitor      = LocalMonitor()
    private(set) var toggleTabHotKey   : KeyboardShortcuts.Name

    var cancellables = Set<AnyCancellable>()
    
    private var overlay: OverlayCoordinator
    
    init(
        deps: OverlayDeps,
        instance : OverlayCoordinator,
        toggleTabHotKey     : KeyboardShortcuts.Name = .toggleTab
    ) {
        self.overlay = instance
        self.settingsService   = deps.settingsService
        self.toggleTabHotKey   = toggleTabHotKey
        
        prepareHotKey()
        /// We Bind For The Pinning Logic, Currently Unused
        
        /// From Mermaid Diagram This is the setupPinningListener()
        DispatchQueue.main.async {
            self.overlay.overlayViewModel?.$isPinned
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
            self.settingsService.modifierKeyPublisher
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
                settingsService.modifierKey == .control ? .control
                : settingsService.modifierKey == .option ? .option
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
            self.localMonitor.start(
                with: self.settingsService.modifierKey
            ) {
                self.onEnd()
            }
            self.overlay.show()
        }
        KeyboardShortcuts.onKeyUp(for: self.toggleTabHotKey) {
            /// If The ModifierKey is still held OR the OverlayViewModel is pinned
            /// just return
            if self.localMonitor.isHeldNow() || (self.overlay.overlayViewModel?.isPinned ?? false)
            {
                return
            }
        }
    }
    
    private func onEnd() {
        /// If Pinned Dont Hide
        guard let overlayViewModel = overlay.overlayViewModel else { return }
        guard !overlayViewModel.isPinned else {
            return
        }
        /// Hide Overlay
        self.overlay.hide()
    }
}
