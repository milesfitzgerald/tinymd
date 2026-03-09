import SwiftUI

enum ViewMode: String, CaseIterable {
    case editor = "Editor"
    case split = "Split"
    case preview = "Preview"
}

struct MainView: View {
    @ObservedObject var workspace: WorkspaceModel
    @State private var viewMode: ViewMode = .split
    @State private var cursorLine: Int = 1

    private var wordCount: Int {
        workspace.currentText.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }

    private var charCount: Int {
        workspace.currentText.count
    }

    private var readingMinutes: Int {
        max(1, wordCount / 238)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            if workspace.sidebarVisible {
                SidebarView(workspace: workspace)
                    .frame(width: 220)

                Rectangle()
                    .fill(Theme.border)
                    .frame(width: 1)
            }

            // Editor + Preview
            VStack(spacing: 0) {
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        if viewMode != .preview {
                            MarkdownEditorView(
                                text: $workspace.currentText,
                                onCursorChange: { line in cursorLine = line }
                            )
                            .frame(width: viewMode == .split ? geo.size.width / 2 : geo.size.width)
                        }

                        if viewMode == .split {
                            Rectangle()
                                .fill(Theme.border)
                                .frame(width: 1)
                        }

                        if viewMode != .editor {
                            MarkdownPreviewView(markdown: workspace.currentText)
                                .frame(width: viewMode == .split ? geo.size.width / 2 : geo.size.width)
                        }
                    }
                }

                StatusBar(
                    cursorLine: cursorLine,
                    wordCount: wordCount,
                    charCount: charCount,
                    readingMinutes: readingMinutes,
                    fileName: workspace.currentFileURL?.lastPathComponent
                )
            }
        }
        .background(Theme.background)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        workspace.sidebarVisible.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Sidebar")
            }

            ToolbarItem(placement: .principal) {
                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .setViewMode)) { notification in
            if let mode = notification.object as? ViewMode {
                viewMode = mode
            }
        }
        .onChange(of: workspace.currentText) { _ in
            workspace.isDirty = true
            workspace.autoSave()
        }
        .navigationTitle(workspace.currentFileURL?.deletingPathExtension().lastPathComponent ?? "Tiny.md")
    }
}

struct StatusBar: View {
    let cursorLine: Int
    let wordCount: Int
    let charCount: Int
    let readingMinutes: Int
    var fileName: String?

    var body: some View {
        HStack {
            Text("Ln \(cursorLine)")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(wordCount) words  ·  \(charCount) chars")
                .frame(maxWidth: .infinity, alignment: .center)

            Text("\(readingMinutes) min read")
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.system(size: 10, weight: .regular, design: .monospaced))
        .foregroundStyle(Theme.text.opacity(0.5))
        .padding(.horizontal, 16)
        .frame(height: 28)
        .background(Theme.chrome)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
    }
}
