//
//  OverlayViewModel.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import Combine

extension OverlayViewModel {
    
    @MainActor
    func resetVisibleApps() {
        visibleApps = []
    }
    
    @MainActor
    private func setVisibleAppsInstant(_ apps: [RunningApp]) {
        revealTask?.cancel()
        resetVisibleApps()
        self.visibleApps = apps
    }
    
    @MainActor
    private func addAppsOneByOne(
        apps: [RunningApp],
        perItemDelay: Duration = .milliseconds(100)
    ) {
        resetVisibleApps()
        revealTask?.cancel()
        revealTask = Task { [weak self] in
            guard let self else { return }
            for app in apps {
                try? await Task.sleep(for: perItemDelay)
                if Task.isCancelled || !isShowing { return }
                withAnimation(AppAnims.loadingAnimation) {
                    self.visibleApps.append(app)
                }
            }
        }
    }
}

class OverlayViewModel: ObservableObject {
    private var revealTask: Task<Void, Never>?
    
    private let runningAppsService  : RunningAppService
    private var settingsService     : any SettingsService
    
    /// Pinned State
    @Published var isPinned: Bool = false
    /// If Shown or Not
    @Published var isShowing: Bool = false
    /// Size of The Overlay
    @Published var comfyTabSize: (radius: CGFloat, thickness: CGFloat) = (130, 80)
    
    
    /// Filtered List of Apps
    @Published var runningApps: [RunningApp] = []
    /// All Running Apps, this is nice when we wanna display the currently running apps
    @Published var allRunningApps: [RunningApp] = []
    @Published var visibleApps: [RunningApp] = []
    
    /// List of All Hidden Apps We Add To
    @Published var hiddenApps: Set<RunningApp> = []
    @Published var closeOnFinderOpen: Bool = false
    
    @Published var isIntroAnimationEnabled: Bool = false
    @Published var showAppNameUnderIcon: Bool = false
    @Published var isHoverEffectEnabled: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(deps: OverlayDeps) {
        self.runningAppsService = deps.runningAppService
        self.settingsService = deps.settingsService
        
        /// When Showing/Hiding we want to get the running apps
        $isShowing
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { isShowing in
                if isShowing {
                    self.getRunningApps()
                } else {
                    Task { @MainActor in
                        self.resetVisibleApps()
                    }
                }
            }
            .store(in: &cancellables)
        
        /// If Running Apps Change we wanna update the visible apps with a nice animation
        /// but only if the user wants it
        $runningApps
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { apps in
                if self.isShowing && apps.count > 0 {
                    if self.isIntroAnimationEnabled {
                        Task { @MainActor in
                            self.addAppsOneByOne(apps: apps)
                        }
                    } else {
                        Task { @MainActor in
                            self.setVisibleAppsInstant(apps)
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        /// Load Changes From Settings
        settingsService.isIntroAnimationEnabledPublisher
            .sink { enabled in
                self.isIntroAnimationEnabled = enabled
            }
            .store(in: &cancellables)
        
        settingsService.showAppNameUnderIconPublisher
            .sink { show in
                self.showAppNameUnderIcon = show
            }
            .store(in: &cancellables)
        
        settingsService.isHoverEffectEnabledPublisher
            .sink { enabled in
                self.isHoverEffectEnabled = enabled
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Utilities
    /// toggles the state of the pin, Hotkey Listens for this value
    public func togglePinned() {
        isPinned.toggle()
    }
    /// Forces if Pinned, to close, this is nice, when finder is opened to close it
    public func onFinderOpen(_ app: RunningApp) {
        app.revealInFinder()
        //        overlay.hide()
    }
    /// Nice Utility Function to Focus the App, Called when we click from the Dial
    public func focusApp(index: Int)  {
        self.runningAppsService.goToApp(runningApps[index])
        //        overlay.hide()
    }
    
    @MainActor
    public func getAppIcon(for app: RunningApp) -> NSImage {
        let image : NSImage? = AppIconManager.appIcons[app.bundleID ?? ""]
        return image ?? AppIconManager.fallbackAppIcon()
    }
    
    // MARK: - Running Apps
    /// Function Gets the Running Apps For The User
    public func getRunningApps() {
        
        /// if Intro is Enabled we clear to show a nice animation of filling
        if settingsService.isIntroAnimationEnabled {
            // Clear first to ensure animation triggers
            self.runningApps = []
        }
        
        // 1) Build a fast lookup for hidden apps (by pid OR bundleID)
        let hiddenPIDs: Set<pid_t> = Set(self.hiddenApps.map { $0.pid })
        let hiddenBundleIDs: Set<String> = Set(self.hiddenApps.compactMap { $0.bundleID })
        
        Task {
            for await app in await runningAppsService.observe() {
                await MainActor.run {
                    
                    self.allRunningApps = app // this cant be filtered
                    
                    let filtered = app.filter { a in
                        if hiddenPIDs.contains(a.pid) { return false }
                        if let bid = a.bundleID, hiddenBundleIDs.contains(bid) { return false }
                        return true
                    }
                    
                    // 3) De-dupe by pid (keeps first occurrence, preserves order)
                    var seen = Set<pid_t>(minimumCapacity: filtered.count)
                    var result: [RunningApp] = []
                    result.reserveCapacity(filtered.count)
                    
                    for a in filtered {
                        if seen.insert(a.pid).inserted {
                            result.append(a)
                        }
                    }
                    
                    self.runningApps = result
                    self.updateRunningAppIcons()
                }
            }
        }
    }
    
    
    // MARK: - Hidden App Stuff
    public func addHiddenApp(_ isOn: Bool,for app: RunningApp) {
        if isOn {
            hiddenApps.insert(app)
            self.runningApps.removeAll { $0 == app }
            Task { [weak self] in
                guard let self else { return }
                /// we just remove it so the UI updates
                await self.runningAppsService.removeFromCache(app)
            }
        } else {
            hiddenApps.remove(app)
            if allRunningApps.contains(app) {
                self.runningApps.append(app)
            }
            //            Task { [weak self] in
            //                guard let self else { return }
            //            }
        }
    }
    
    private func loadHiddenItems() {
        
    }
    
    // MARK: - Private API's
    
    /// Update Running App Icons Internally, this can be nicely for `getAppIcon()`
    @MainActor
    private func updateRunningAppIcons() {
        runningApps.forEach { app in
            let url = app.url
            let bundle = app.bundleID ?? ""
            AppIconManager.loadAppIcon(for: url,bundleID: bundle) { _ in
                self.objectWillChange.send()
            }
        }
    }
}
