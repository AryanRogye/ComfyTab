//
//  PermissionsView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import SwiftUI

// TODO: Move to a view model
public struct PermissionsView: View {
    
    @EnvironmentObject var viewModel: PermissionViewModel
    
    public var body: some View {
        SettingsContainerView {
             SettingsSection {
                accessibilityPermissionsView
                     .padding(8)
            }
        }
    }
    
    private var accessibilityPermissionsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Accessibility Permissions")
                
                Spacer()
                
                Button(action: {
                    viewModel.permissionService.requestAcessibilityPermission()
                    viewModel.permissionService.openPermissionSettings()
                }) {
                    Group {
                        if viewModel.permissionService.isAccessibilityEnabled {
                            Text("Enabled")
                                .foregroundColor(.green)
                        } else {
                            Text("Disabled")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewModel.permissionService.isAccessibilityEnabled
                                  ? Color.green.opacity(0.2)
                                  : Color.red.opacity(0.2)
                            )
                    }
                }
                .disabled(viewModel.permissionService.isAccessibilityEnabled)
                .buttonStyle(.plain)
            }
            
            HStack {
                Text("Required to control app switching")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(action: viewModel.permissionService.openPermissionSettings) {
                    Text("Check Anyways?")
                        .font(.caption)
                }
                .buttonStyle(.link)
            }
        }
    }
}
