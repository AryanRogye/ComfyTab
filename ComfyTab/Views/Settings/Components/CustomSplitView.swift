//
//  CustomSplitView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import AppKit
import SwiftUI

/// Main Wrapper For Settings Page
/// If I just ignored the AppWindow, I am also just able to just use this as well, just no nice window
struct ComfySplitView<Sidebar: View, Content: View>: NSViewControllerRepresentable {
    
    var sidebar: () -> Sidebar
    var content: () -> Content
    
    init (
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.sidebar = sidebar
        self.content = content
    }
    
    func makeNSViewController(context: Context) -> NSSplitViewController {
        /// Create the controller
        let controller = SplitViewController {
            sidebar()
        } content: {
            content()
        }
        
        return controller
    }
    
    /// update if the views change
    func updateNSViewController(_ vc: NSSplitViewController, context: Context) {
        guard let svc = vc as? SplitViewController<Sidebar, Content> else { return }
        svc.reload(sidebar: sidebar(), content: content())
    }
}


/// SplitView Controller - Main Settings Controller
@MainActor
class SplitViewController<Sidebar: View, Content: View>: NSSplitViewController {
    
    
    /// From What I understand this is not a closure because
    /// the whole views dont need to be rebuilt from scratch
    var sidebar: Sidebar
    var content: Content
    
    lazy var sidebarHost = NSHostingController(rootView: sidebar)
    lazy var contentHost = NSHostingController(rootView: content)
    
    init(
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.sidebar = sidebar()
        self.content = content()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        splitView.autosaveName = "SettingsSplitVC"
        
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarHost)
        let contentItem = NSSplitViewItem(viewController: contentHost)
        
        // sidebar
        sidebarItem.canCollapse = false
        sidebarItem.titlebarSeparatorStyle = .none
        sidebarItem.holdingPriority = .defaultHigh
        sidebarItem.minimumThickness = 150
        sidebarItem.allowsFullHeightLayout = true
        
        // content item
        contentItem.canCollapse = false
        contentItem.holdingPriority = .defaultLow
        contentItem.allowsFullHeightLayout = true
        
        addSplitViewItem(sidebarItem)
        addSplitViewItem(contentItem)
    }
    
    // MARK: hide the divider
    override func splitView(
        _ splitView: NSSplitView,
        shouldHideDividerAt dividerIndex: Int
    ) -> Bool {
        return true
    }
    
    override func splitView(
        _ splitView: NSSplitView,
        effectiveRect proposedEffectiveRect: NSRect,
        forDrawnRect drawnRect: NSRect,
        ofDividerAt dividerIndex: Int
    ) -> NSRect {
        return .zero
    }
    
    func reload(sidebar: Sidebar, content: Content) {
        self.sidebar = sidebar
        self.content = content
        sidebarHost.rootView = sidebar
        contentHost.rootView = content
    }
}
