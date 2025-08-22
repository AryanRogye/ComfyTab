//
//  InstalledAppManager.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import Combine

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
            return InstalledAppFetcher.fetchApps(from: from)
        }
        
        currentTask = task
        return await task.value
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
