//
//  ModifierKeyMonitor.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import Cocoa

class ModifierComboMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    var onTabPressed: (() -> Void)?
    
    var onModifierPressed: (() -> Void)?
    var onModifierReleased: (() -> Void)?
    
    private var modifierPressed = false
    var modifierKey: ModifierKey
    
    init(modifierKey: ModifierKey) {
        self.modifierKey = modifierKey
        start()
    }
    
    deinit {
        stop()
    }
    
    func start() {
        guard eventTap == nil else { return }
        
        let mask: CGEventMask = (1 << CGEventType.flagsChanged.rawValue) | (1 << CGEventType.keyDown.rawValue)
        
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                     place: .headInsertEventTap,
                                     options: .defaultTap,
                                     eventsOfInterest: mask,
                                     callback: { _, type, event, refcon in
            let monitor = Unmanaged<ModifierComboMonitor>.fromOpaque(refcon!).takeUnretainedValue()
            return monitor.handle(event: event, type: type)
        }, userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        
        guard let eventTap = eventTap else {
            print("⚠️ Failed to create event tap.")
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        self.eventTap = nil
        self.runLoopSource = nil
    }
    
    
    /// Function to handle the events
    private func handle(
        event: CGEvent,
        type: CGEventType
    ) -> Unmanaged<CGEvent>? {
        
        let flags = event.flags
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        switch type {
        case .flagsChanged:
            
            /// If The Modifier Key Is Pressed
            let modifierKeyDown: Bool = isModifierPressed(
                flags: flags,
                modifierKey
            )
            
            /// if changed locally vs globally
            if modifierPressed && !modifierKeyDown {
                modifierPressed = false   /// Assignment
                /// do the release action
                DispatchQueue.main.async {
                    self.onModifierReleased?()
                }
            }
            /// set flag to true
            else if modifierKeyDown {
                modifierPressed = true
            }
        case .keyDown:
            /// This is if option and the Carbon Code 48 (Tab) is being held
            if modifierPressed && keyCode == 48 {
                DispatchQueue.main.async {
                    self.onModifierPressed?()
                }
            }
        default:
            break
        }
        
        return Unmanaged.passUnretained(event)
    }
    
    private func isModifierPressed(
        flags: CGEventFlags,
        _ modifier: ModifierKey
    ) -> Bool {
        switch self.modifierKey {
        case .option:
            return flags.contains(.maskAlternate) // MaskAlternate means Option
        case .control:
            return flags.contains(.maskControl) // MaskControl means Control
        case .shift:
            return flags.contains(.maskShift) // MaskShift means Shift
        }
    }
    
    /// Function used to check if the modifier is held globally, used by pin logic
    public func isModifierPressedGlobally() -> Bool {
        switch self.modifierKey {
        case .option:
            return CGEventSource.flagsState(.combinedSessionState).contains(.maskAlternate)
        case .control:
            return CGEventSource.flagsState(.combinedSessionState).contains(.maskControl)
        case .shift:
            return CGEventSource.flagsState(.combinedSessionState).contains(.maskShift)
        }
    }
}
