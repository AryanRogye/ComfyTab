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
    
    var onOptionTabPressed: (() -> Void)?
    var onTabPressed: (() -> Void)?
    var onOptionReleased: (() -> Void)?
    
    private var optionPressed = false
    
    init() {
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
    private func handle(event: CGEvent, type: CGEventType) -> Unmanaged<CGEvent>? {
        let flags = event.flags
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        switch type {
        case .flagsChanged:
            
            /// This is if option is pressed in the moment
            let optionNowDown = flags.contains(.maskAlternate)
            
            /// if changed locally vs globally
            if optionPressed && !optionNowDown {
                optionPressed = false   /// Assignment
                /// do the release action
                DispatchQueue.main.async {
                    self.onOptionReleased?()
                }
            }
            /// set flag to true
            else if optionNowDown {
                optionPressed = true
            }
        case .keyDown:
            /// This is if option and the Carbon Code 48 (Tab) is being held
            if optionPressed && keyCode == 48 {
                DispatchQueue.main.async {
                    self.onOptionTabPressed?()
                }
            }
        default:
            break
        }
        
        return Unmanaged.passUnretained(event)
    }
    
    /// Function used to check if option is held globally, used by pin logic
    func isOptionHeldGlobally() -> Bool {
        return CGEventSource.flagsState(.combinedSessionState).contains(.maskAlternate)
    }
}
