//
//  InstalledAppManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import Combine

final class InstalledAppManager: ObservableObject {
    let installedAppFetcher = InstalledAppFetcher()
    
    @Published var installedApps: [InstalledApp] = []
    
    init() {
        installedApps = installedAppFetcher.fetchApps()
    }
}
