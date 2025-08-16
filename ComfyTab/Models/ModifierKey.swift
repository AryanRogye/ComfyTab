//
//  ModifierKey.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/16/25.
//

import AppKit

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
