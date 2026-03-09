import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Section {
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
    }
}

extension Notification.Name {
    static let setViewMode = Notification.Name("setViewMode")
}
