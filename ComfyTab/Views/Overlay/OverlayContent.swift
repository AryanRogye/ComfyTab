//
//  OverlayContent.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI

struct OverlayContent: View {
    
    @EnvironmentObject var viewModel : OverlayViewModel
    
    /// This Represents the Entire Screen
    /* LOGIC:
     /// We Push It To The Center Vertically With VStack { Spacer() /**Content */ Spacer() }
     /// ==================================|
     /// |                                 |
     /// |            Spacer()             |
     /// |_________________________________|
     /// |_________________________________|
     /// |                                 |
     /// |            Spacer()             |
     /// |                                 |
     /// ==================================|
     /// And Same Logic Is Applied to the Center Horizontally HStack { Spacer() /**Content */ Spacer() }
     /// ==================================|
     /// |                                 |
     /// |            Spacer()             |
     /// |_________________________________|
     /// |_Spacer()___|content|___Spacer()_|
     /// |                                 |
     /// |            Spacer()             |
     /// |                                 |
     /// ==================================|
     */
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                overlay
                    /// Mix of Scale and offset gives it that nice come up feeling
                    .scaleEffect(viewModel.isShowing ? 1.0 : 0.95)
                    /// Gives Appearence of coming from the bottom
                    .offset(y: viewModel.isShowing ? 0 : 10)
                    /// hide to unhide
                    .opacity(viewModel.isShowing ? 1.0 : 0.0)
                    /// transition to a nonblur when showing
                    .blur(radius: viewModel.isShowing ? 0 : 1.5)
                    .shadow(radius: viewModel.isShowing ? 2 : 1)
                    /// Animation Logic
                    .animation(
                        .interpolatingSpring(
                            stiffness: 120,
                            damping: 22
                        ),
                        value: viewModel.isShowing
                    )
                Spacer()
            }
            Spacer()
        }
    }
    
    private var overlay: some View {
        ComfyTab()
    }
}
