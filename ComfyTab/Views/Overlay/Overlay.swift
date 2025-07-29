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
    let overlayWidth     : CGFloat = 800
    let overlayHeight    : CGFloat = 400

    let windowManager: WindowManager
    lazy var overlayViewModel = OverlayViewModel(windowManager: windowManager)

    init(windowManager: WindowManager) {
        self.windowManager = windowManager
        prepareOverlay()
    }
    
    // MARK: - Show Hide Overlay
    public func show() {
        guard let overlay = overlay else {
            prepareOverlay()
            return
        }
        
        if !overlay.isVisible {
            calculateNewScreenPosition()
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
    
    // MARK: - Calculate New Show
    
    /// Function will use a new NSScreen.main becuase the user may have a different screen in use
    private func calculateNewScreenPosition() {
        guard let screen = getScreenUnderMouse() else { return }
        overlay.setFrame(centerRect(on: screen), display: true, animate: false)
    }
    
    // MARK: - Prepare Overlay
    private func prepareOverlay() {
        guard let screen = getScreenUnderMouse() else { return }
        
        let panelRect = centerRect(on: screen)
        
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

/// Quick Mouse Functions
extension Overlay {
    private func getScreenUnderMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) })
    }
    
    private func centerRect(on screen: NSScreen) -> NSRect {
        let frame = screen.frame
        return NSRect(
            x: frame.origin.x + (frame.width - overlayWidth) / 2,
            y: frame.origin.y + (frame.height - overlayHeight) / 2,
            width: overlayWidth,
            height: overlayHeight
        )
    }
}
