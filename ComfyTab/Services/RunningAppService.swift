//
//  RunningAppService.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/20/25.
//

protocol RunningAppService: Actor, Sendable {
    func snapshot() async -> [RunningApp]
    func observe() -> AsyncStream<[RunningApp]>
    func removeFromCache(_ app: RunningApp) async
    nonisolated func goToApp(_ app: RunningApp)
}
