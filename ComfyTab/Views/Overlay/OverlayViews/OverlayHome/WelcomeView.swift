//
//  WelcomeView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject var viewModel : OverlayViewModel
    
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("Welcome to ComfyTab!")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Curate your focus. Switch with intention.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                goWithTheFlow
                setYourVibe
            }
            .padding(.horizontal)
            .padding(.top, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var goWithTheFlow: some View {
        Button(action: {
            viewModel.switchOverlayState(to: .goWithFlow)
        }) {
            Text("Go With The Flow")
                .font(.headline)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1))
                }
        }
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .buttonStyle(.plain)
    }
    
    private var setYourVibe: some View {
        Button(action: {
            viewModel.switchOverlayState(to: .configureVibe)
        }) {
            Text("Set Your Vibe")
                .font(.headline)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1))
                }
        }
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .buttonStyle(.plain)
    }
}
