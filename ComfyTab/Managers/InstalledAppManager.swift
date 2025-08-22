//
//  InstalledAppManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

/// Service so we can retrive the installed Apps in a background Service
final actor InstalledAppFetcherService {
    private var currentTask : Task<[InstalledApp], Never>?
    
    deinit {
        currentTask?.cancel()
    }
    
    public func fetchApps(
        from: [URL]
    ) async -> [InstalledApp] {
        currentTask?.cancel()
        
        /// Start A Background Task That return [InstalledApp
        let task = Task<[InstalledApp], Never> {
            if Task.isCancelled { return [] }
            return await self.fetchApps(from: from)
        }
        
        currentTask = task
        return await task.value
    }
    
    private func fetchInstalledApps(
        from directoryOfApps: [URL],
        timeout: TimeInterval = 1.5
    ) -> [InstalledApp] {
        let fm = FileManager.default
        let keys: Set<URLResourceKey> = [.contentTypeKey, .localizedNameKey]
        
        var results : [InstalledApp] = []
        
        for root in directoryOfApps where fm.fileExists(atPath: root.path) {
            guard let e = fm.enumerator(
                at: root,
                includingPropertiesForKeys: Array(keys),
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { continue }
            
            for case let url as URL in e {
                // Only keep .app bundles
                guard (try? url.resourceValues(forKeys: keys))?
                    .contentType?
                    .conforms(to: .applicationBundle) == true
                else { continue }
                
                let bundle = Bundle(url: url)
                
                let name = (try? url.resourceValues(forKeys: [.localizedNameKey]))?.localizedName
                ?? bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                ?? bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? url.deletingPathExtension().lastPathComponent
                
                let bundleID = bundle?.bundleIdentifier
                let pid = bundleID.flatMap {
                    NSRunningApplication.runningApplications(withBundleIdentifier: $0).first?.processIdentifier
                }
                
                results.append(InstalledApp(url: url, name: name, bundleID: bundleID))
            }
            
            var seen = Set<String>()
            return results.compactMap { app in
                let key = app.bundleID ?? app.url.path
                return seen.insert(key).inserted ? app : nil
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        
        return []
    }
}

final class InstalledAppManager : InstalledAppService, ObservableObject {
    
    @Published var installedApps: [InstalledApp] = []
    
    var installedAppsPublisher: AnyPublisher<[InstalledApp], Never> {
        $installedApps
            .eraseToAnyPublisher()
    }
    
    
    private(set) var directoryOfApps: [URL] = []
    
    private var cancellables: Set<AnyCancellable> = []
    private let installedAppFetcherService = InstalledAppFetcherService()
    
    init(settingsService: SettingsService) {
        
        self.directoryOfApps = settingsService.directoriesOfApps
        fetchApps()
        
        /// Bind For Any Changes
        settingsService.directoriesOfAppsPublisher
            .removeDuplicates()
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
            .sink { [weak self] directoryOfApps in
                guard let self = self else { return }
                self.updateDirectoryOfApps(with: directoryOfApps)
            }
            .store(in: &cancellables)
    }
    
    private func updateDirectoryOfApps(with urls: [URL]) {
        self.directoryOfApps = urls
        fetchApps()
    }
    
    public func fetchApps() {
        Task { @MainActor in
            let apps = await installedAppFetcherService.fetchApps(from: directoryOfApps)
            self.installedApps = apps
        }
    }
}
