//
//  Overlay.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import Combine
import AppKit
import SwiftUI

class FocusablePanel: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
    override var canBecomeMain: Bool {
        return true
    }
}

class Overlay: ObservableObject {
    
    var overlay: NSPanel!
    
    let overlayViewModel = OverlayViewModel()
    let overlayWidth     : CGFloat = 800
    let overlayHeight    : CGFloat = 400
    
    init() {
        prepareOverlay()
    }
    
    // MARK: - Show Hide Overlay
    public func show() {
        guard let overlay = overlay else {
            prepareOverlay()
            return
        }
        
        if !overlay.isVisible {
            NSApp.activate(ignoringOtherApps: true)
            overlay.makeKeyAndOrderFront(nil)
        }
    }
    
    public func hide() {
        guard let overlay = overlay else { return }
        
        if overlay.isVisible {
            overlay.orderOut(nil)
        }
    }
    
    // MARK: - Prepare Overlay
    private func prepareOverlay() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        
        let panelRect = NSRect(
            x: (screenFrame.width - overlayWidth) / 2,
            y: (screenFrame.height - overlayHeight) / 2,
            width: overlayWidth,
            height: overlayHeight
        )
        
        overlay = FocusablePanel(
            contentRect: panelRect,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        /// Allow content to draw outside panel bounds
        overlay.contentView?.wantsLayer = true
        overlay.title = "ComfyNotch"
        
        let overlayRaw = CGWindowLevelForKey(.overlayWindow)
        overlay.level = NSWindow.Level(rawValue: Int(overlayRaw))
        
        overlay.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        overlay.isMovableByWindowBackground = false
        overlay.backgroundColor = .clear
        overlay.isOpaque = false
        overlay.hasShadow = false
        
        
        let contentView = OverlayContent()
            .environmentObject(overlayViewModel)
        
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = panelRect
        
        /// Allow hosting view to overflow
        hostingView.wantsLayer = true
        hostingView.layer?.masksToBounds = false
        
        overlay.contentView = hostingView
        
        self.hide()
    }
}
