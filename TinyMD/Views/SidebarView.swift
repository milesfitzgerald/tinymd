import SwiftUI

struct SidebarView: View {
    @ObservedObject var workspace: WorkspaceModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                if let root = workspace.rootURL {
                    Text(root.lastPathComponent)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Theme.text.opacity(0.6))
                        .lineLimit(1)
                } else {
                    Text("No Folder")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Theme.text.opacity(0.4))
                }

                Spacer()

                Button(action: { workspace.createNewFile() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.accent)
                }
                .buttonStyle(.plain)
                .help("New File")
                .disabled(workspace.rootURL == nil)

                Button(action: { workspace.chooseDirectory() }) {
                    Image(systemName: "folder.badge.gearshape")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.accent)
                }
                .buttonStyle(.plain)
                .help("Change Folder")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Theme.chrome)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 1)
            }

            // File list
            if workspace.rootURL == nil {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 28))
                        .foregroundStyle(Theme.accent.opacity(0.5))
                    Text("Open a folder to get started")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Theme.text.opacity(0.4))
                    Button("Choose Folder") {
                        workspace.chooseDirectory()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.accent.opacity(0.1))
                    .cornerRadius(4)
                }
                Spacer()
            } else if workspace.files.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Text("No markdown files")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Theme.text.opacity(0.4))
                    Button("Create New File") {
                        workspace.createNewFile()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.accent)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(workspace.files) { item in
                            FileRowView(item: item, workspace: workspace, depth: 0)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .background(Theme.chrome)
    }
}

struct FileRowView: View {
    let item: FileItem
    @ObservedObject var workspace: WorkspaceModel
    let depth: Int
    @State private var isExpanded: Bool = true
    @State private var isRenaming: Bool = false
    @State private var renameText: String = ""

    var isSelected: Bool {
        workspace.currentFileURL == item.url
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                if item.isDirectory {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Theme.text.opacity(0.3))
                        .frame(width: 10)
                }

                Image(systemName: item.icon)
                    .font(.system(size: 11))
                    .foregroundStyle(isSelected ? Theme.accent : Theme.text.opacity(0.5))

                if isRenaming {
                    RenameField(
                        text: $renameText,
                        onCommit: { commitRename() },
                        onCancel: { isRenaming = false }
                    )
                    .font(.system(size: 12, design: .monospaced))
                } else {
                    Text(item.name)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(isSelected ? Theme.accent : Theme.text.opacity(0.8))
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.leading, CGFloat(depth * 16) + (item.isDirectory ? 8 : 18))
            .padding(.trailing, 8)
            .padding(.vertical, isRenaming ? 2 : 5)
            .background(isSelected ? Theme.accent.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
            .onTapGesture {
                if isRenaming { return }
                if item.isDirectory {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isExpanded.toggle()
                    }
                } else {
                    workspace.openFile(item.url)
                }
            }
            .gesture(
                TapGesture(count: 2).onEnded {
                    if !item.isDirectory {
                        startRename()
                    }
                }
            )
            .contextMenu {
                if !item.isDirectory {
                    Button("Rename") {
                        startRename()
                    }
                    Divider()
                    Button("Delete") {
                        workspace.deleteFile(item.url)
                    }
                    Divider()
                    Button("Reveal in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting([item.url])
                    }
                }
            }

            if item.isDirectory && isExpanded, let children = item.children {
                ForEach(children) { child in
                    FileRowView(item: child, workspace: workspace, depth: depth + 1)
                }
            }
        }
    }

    private func startRename() {
        renameText = item.url.deletingPathExtension().lastPathComponent
        isRenaming = true
    }

    private func commitRename() {
        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            isRenaming = false
            return
        }
        let ext = item.url.pathExtension
        let newName = trimmed.hasSuffix(".\(ext)") ? trimmed : "\(trimmed).\(ext)"
        workspace.renameFile(item.url, to: newName)
        isRenaming = false
    }
}

struct RenameField: NSViewRepresentable {
    @Binding var text: String
    var onCommit: () -> Void
    var onCancel: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()
        field.stringValue = text
        field.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        field.textColor = NSColor(Theme.accent)
        field.backgroundColor = NSColor(calibratedWhite: 0.1, alpha: 1.0)
        field.isBordered = true
        field.focusRingType = .none
        field.delegate = context.coordinator
        field.cell?.isScrollable = true
        field.cell?.lineBreakMode = .byTruncatingTail

        DispatchQueue.main.async {
            field.selectText(nil)
            field.window?.makeFirstResponder(field)
        }
        return field
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: RenameField

        init(_ parent: RenameField) {
            self.parent = parent
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            parent.text = field.stringValue
            parent.onCommit()
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                parent.onCancel()
                return true
            }
            return false
        }
    }
}
