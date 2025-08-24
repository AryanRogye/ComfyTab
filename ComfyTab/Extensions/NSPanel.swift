//
//  NSPanel.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

import AppKit

class FocusablePanel: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
    override var canBecomeMain: Bool {
        return true
    }
}
