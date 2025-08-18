//
//  LocalMonitor.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/18/25.
//

import Cocoa

class LocalMonitor {
    
    private var modifierMonitor: Any?
    
    /// Flag to know if the modifier key is pressed locally or not
    private(set) var isLocallyPressingModifier : Bool = false
    private var activeTarget: NSEvent.ModifierFlags?
    
    init() {
        
    }
    
    deinit { stop() }
    
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
        /// Stop Before Starting
        
        isLocallyPressingModifier = isHeldNow()
        
        modifierMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.flagsChanged]
        ) { [weak self] event in
            guard let self = self else { return event }
            isLocallyPressingModifier = isHeldNow()
            
            if !isLocallyPressingModifier {
                onEnd()
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
        ) { [weak self] _ in
            self?.stop()
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
