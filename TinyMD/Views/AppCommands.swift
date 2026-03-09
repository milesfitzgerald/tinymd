import SwiftUI

struct AppCommands: Commands {
    @ObservedObject var workspace: WorkspaceModel

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Markdown File") {
                workspace.createNewFile()
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
            .disabled(workspace.rootURL == nil)

            Divider()

            Button("Open Folder...") {
                workspace.chooseDirectory()
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])
        }

        CommandGroup(after: .toolbar) {
            Section {
                Button("Toggle Sidebar") {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        workspace.sidebarVisible.toggle()
                    }
                }
                .keyboardShortcut("b", modifiers: .command)

                Divider()

                Button("Editor Only") {
                    NotificationCenter.default.post(
                        name: .setViewMode, object: ViewMode.editor
                    )
                }
                .keyboardShortcut("1", modifiers: [.command, .shift])

                Button("Split View") {
                    NotificationCenter.default.post(
                        name: .setViewMode, object: ViewMode.split
                    )
                }
                .keyboardShortcut("2", modifiers: [.command, .shift])

                Button("Preview Only") {
                    NotificationCenter.default.post(
                        name: .setViewMode, object: ViewMode.preview
                    )
                }
                .keyboardShortcut("3", modifiers: [.command, .shift])
            }
        }

        CommandGroup(replacing: .saveItem) {
            Button("Save") {
                workspace.saveCurrentFile()
            }
            .keyboardShortcut("s", modifiers: .command)
            .disabled(workspace.currentFileURL == nil)
        }
    }
}

extension Notification.Name {
    static let setViewMode = Notification.Name("setViewMode")
}
