//
//  BehaviorViewModel.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

import Combine
import SwiftUI

@MainActor
class BehaviorViewModel: ObservableObject {
    
    var settingsService : SettingsService
    var installedAppService : InstalledAppService
    
    /// Modifier Key Binding
    var modifierKey : Binding<ModifierKey> {
        Binding(
            get: { self.settingsService.modifierKey },
            set: { self.settingsService.modifierKey = $0 }
        )
    }
    
    /// Intro Animation Binding
    var isIntroAnimationEnabled: Binding<Bool> {
        Binding(
            get: { self.settingsService.isIntroAnimationEnabled },
            set: { self.settingsService.isIntroAnimationEnabled = $0 }
        )
    }
    
    /// showAppNameUnderIcon Binding
    var showAppNameUnderIcon: Binding<Bool> {
        Binding(
            get: { self.settingsService.showAppNameUnderIcon },
            set: { self.settingsService.showAppNameUnderIcon = $0 }
        )
    }
    
    /// isHoverEffectEnabled Binding
    var isHoverEffectEnabled: Binding<Bool> {
        Binding(
            get: { self.settingsService.isHoverEffectEnabled },
            set: { self.settingsService.isHoverEffectEnabled = $0 }
        )
    }
    

    init(deps: BehaviorDeps) {
        self.settingsService = deps.settingsService
        self.installedAppService = deps.installedAppService
    }
    
    // MARK: - Related To Installed App Settings
    /// Done Loading
    var doneLoading = false

    public func getIcon(for app: InstalledApp) -> NSImage {
        let image : NSImage? = AppIconManager.appIcons[app.bundleID ?? ""]
        return image ?? AppIconManager.fallbackAppIcon()
    }
    
    public func updateIcons(_ apps: [InstalledApp]) {
        apps.forEach { app in
            
            let url = app.url
            let bundle = app.bundleID ?? ""
            
            AppIconManager.loadAppIcon(for: url,bundleID: bundle) { _ in }
        }
        doneLoading = true
    }
    
    public func removeIconsFromCache(_ apps: [InstalledApp]) {
        apps.forEach {
            AppIconManager.removeAppIcon(for: $0.bundleID ?? "")
        }
    }
}
