//
//  AppDelegate.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import AppKit
import Combine

final class AppEnv : OverlayDeps, SettingsDeps, BehaviorDeps, GeneralDeps, PermissionDeps {
    var settingsManager = SettingsManager()
    lazy var installedAppManager : InstalledAppManager = InstalledAppManager(settingsService: settingsService)
    
    var runningAppService: any RunningAppService = RunningAppManager()
    var settingsService : any SettingsService { settingsManager }
    var installedAppService: any InstalledAppService { installedAppManager }
    var permissionService : any PermissionService { PermissionManager() }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var appCoordinator : AppCoordinator
    var appEnv = AppEnv()
    
    @MainActor
    override init() {
        appCoordinator = AppCoordinator(env: appEnv)
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
