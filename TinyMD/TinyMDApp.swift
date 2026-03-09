import SwiftUI

@main
struct TinyMDApp: App {
    @StateObject private var workspace = WorkspaceModel()

    var body: some Scene {
        WindowGroup {
            MainView(workspace: workspace)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unifiedCompact)
        .commands {
            AppCommands(workspace: workspace)
        }
    }
}
