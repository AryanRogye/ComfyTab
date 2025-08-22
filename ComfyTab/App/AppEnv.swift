//
//  AppEnv.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/22/25.
//

final class AppEnv : OverlayDeps, SettingsDeps, BehaviorDeps, GeneralDeps, PermissionDeps {
    var settingsManager = SettingsManager()
    lazy var installedAppManager : InstalledAppManager = InstalledAppManager(settingsService: settingsService)
    
    var runningAppService: any RunningAppService = RunningAppManager()
    var settingsService : any SettingsService { settingsManager }
    var installedAppService: any InstalledAppService { installedAppManager }
    var permissionService : any PermissionService { PermissionManager() }
}
