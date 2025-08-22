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
public class HotkeyCoordinator {
    
    private(set) var settingsService   : SettingsService
    private(set) var localMonitor      = LocalMonitor()
    private(set) var toggleTabHotKey   : KeyboardShortcuts.Name
    
    var cancellables = Set<AnyCancellable>()
    
    private var onShow: (() -> Void)
    private var onHide: (() -> Void)
    
    private var overlayViewModel: OverlayViewModel
    
    init(
        deps: OverlayDeps,
        toggleTabHotKey     : KeyboardShortcuts.Name = .toggleTab,
        overlayViewModel    : OverlayViewModel,
        onShow              : @escaping (() -> Void),
        onHide              : @escaping (() -> Void)
    ) {
        self.settingsService   = deps.settingsService
        self.overlayViewModel  = overlayViewModel
        self.toggleTabHotKey   = toggleTabHotKey
        self.onShow            = onShow
        self.onHide            = onHide
        
        prepareHotKey()
        /// We Bind For The Pinning Logic, Currently Unused
        
        /// From Mermaid Diagram This is the setupPinningListener()
        DispatchQueue.main.async {
            self.overlayViewModel.$isPinned
                .sink { [weak self] isPinned in
                    guard let self = self else { return }
                    if !isPinned {
                        print("is Not Held Triggered")
                        /// We Wanna Check if Option is Being Held
                        /// if it is not then we wanna hide again
                        if !self.localMonitor.isHeldNow() {
                            self.onHide()
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
            self.onShow()
        }
        KeyboardShortcuts.onKeyUp(for: self.toggleTabHotKey) {
            /// If The ModifierKey is still held OR the OverlayViewModel is pinned
            /// just return
            if self.localMonitor.isHeldNow() || (self.overlayViewModel.isPinned)
            {
                return
            }
        }
    }
    
    private func onEnd() {
        /// If Pinned Dont Hide
        guard !overlayViewModel.isPinned else {
            return
        }
        /// Hide Overlay
        self.onHide()
    }
}

// MARK: - Local Monitor for Modifier Key
extension HotkeyCoordinator {
    @MainActor
    final class LocalMonitor {
        
        private var modifierMonitor: Any?
        
        /// Flag to know if the modifier key is pressed locally or not
        private(set) var isLocallyPressingModifier : Bool = false
        private var activeTarget: NSEvent.ModifierFlags?
        
        init() {
            
        }
        
        deinit {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.stop()
            }
        }
        
        public func isHeldNow() -> Bool {
            guard let activeTarget = activeTarget else { return false }
            let flags = NSEvent.modifierFlags.intersection(.deviceIndependentFlagsMask)
            return flags.contains(activeTarget)
        }
        
        public func start(
            with modifierKey: ModifierKey,
            onEnd: @escaping () -> Void
        ) {
            
            if modifierMonitor != nil { return }
            
            let target = map(modifierKey)
            activeTarget = target
            
            isLocallyPressingModifier = isHeldNow()
            
            modifierMonitor = NSEvent.addLocalMonitorForEvents(
                matching: [.flagsChanged]
            ) { [weak self] event in
                guard let self = self else { return event }
                isLocallyPressingModifier = isHeldNow()
                
                /// This is when we let go of the modifier key
                if !isLocallyPressingModifier {
                    onEnd() /// passed in
                    self.stop()
                }
                
                return event
            }
            
            // Safety: if we started during an event gap, reconcile next tick
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isLocallyPressingModifier = self.isHeldNow()
                if !self.isLocallyPressingModifier {
                    onEnd()
                    self.stop()
                }
            }
            
            // ensure we never get stuck if app deactivates
            NotificationCenter.default.addObserver(
                forName: NSApplication.didResignActiveNotification,
                object: nil, queue: .main
            ) { _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.stop()
                }
            }
        }
        
        public func stop() {
            if let m = modifierMonitor {
                NSEvent.removeMonitor(m)
                modifierMonitor = nil
            }
            activeTarget = nil
            isLocallyPressingModifier = false
        }
        
        private func map(_ modifierKey: ModifierKey) -> NSEvent.ModifierFlags {
            switch modifierKey {
            case .option:  return .option
            case .control: return .control
            case .shift:   return .shift
            }
        }
    }
}
