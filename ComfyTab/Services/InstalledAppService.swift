//
//  InstalledAppService.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

import Combine

protocol InstalledAppService {
    var installedApps: [InstalledApp] { get set }
    var installedAppsPublisher: AnyPublisher<[InstalledApp], Never> { get }
    func fetchApps()
}
