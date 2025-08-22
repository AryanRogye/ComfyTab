//
//  WindowCoordinator.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

import Foundation
import AppKit
import SwiftUI

/// Window Coordinator manages the lifecycle of multiple windows in the application.
class WindowCoordinator {
    private var windows : [String: NSWindow] = [:]
    
    deinit {
        // Clean up all windows when the coordinator is deinitialized
        for window in windows.values {
            window.close()
        }
        windows.removeAll()
    }
    
    func showWindow(
        id: String,
        title: String,
        content: some View,
        size: NSSize = .init(width: 600, height: 400)
    ) {
        if let window = windows[id] {
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Match SwiftUI window modifiers
        window.title = title
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.center()
        
        let hostingView = NSHostingView(rootView: content)
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        window.contentView = hostingView
        
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        windows[id] = window
    }
    
    func closeWindow(id: String) {
        windows[id]?.close()
        windows[id] = nil
    }
}
