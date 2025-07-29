//
//  OverlayGoWithFlow.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import Combine

enum OverlayGoWithFlowState: String, CaseIterable {
    case chosen = "Chosen Apps"
    case configure = "Configure"
}	

class OverlayGoWithFlowViewModel: ObservableObject {
    @Published var state: OverlayGoWithFlowState = .chosen
}

struct OverlayGoWithFlow: View {
    
    @StateObject private var selfViewModel = OverlayGoWithFlowViewModel()
    @EnvironmentObject var viewModel: OverlayViewModel
    
    var body: some View {
        VStack {
            HStack {
                ForEach(OverlayGoWithFlowState.allCases, id: \.self) { state in
                    Button(action: {
                        selfViewModel.state = state
                    }) {
                        Text(state.rawValue)
                            .frame(width: 70)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            }
                    }
                }
            }
            switch selfViewModel.state {
            case .chosen:
                chosenFlow
            case .configure:
                OverlayConfigureVibe()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            viewModel.syncRunningApps()
        }
    }
    
    private var configureFlow: some View {
        VStack {
            
        }
    }
    
    private var chosenFlow: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(viewModel.chosenApps, id: \.self) { app in
                Button(action: {
                    viewModel.switchTab(app)
                }) {
                    Text(app.name)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.regularMaterial)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
