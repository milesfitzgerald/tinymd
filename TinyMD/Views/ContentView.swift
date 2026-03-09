import SwiftUI

enum ViewMode: String, CaseIterable {
    case editor = "Editor"
    case split = "Split"
    case preview = "Preview"
}

struct ContentView: View {
    @Binding var document: MarkdownDocument
    @State private var viewMode: ViewMode = .split
    @State private var cursorLine: Int = 1

    private var wordCount: Int {
        document.text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }

    private var charCount: Int {
        document.text.count
    }

    private var readingMinutes: Int {
        max(1, wordCount / 238)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main content
            GeometryReader { geo in
                HStack(spacing: 0) {
                    if viewMode != .preview {
                        MarkdownEditorView(
                            text: $document.text,
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
                        MarkdownPreviewView(markdown: document.text)
                            .frame(width: viewMode == .split ? geo.size.width / 2 : geo.size.width)
                    }
                }
            }

            // Status bar
            StatusBar(
                cursorLine: cursorLine,
                wordCount: wordCount,
                charCount: charCount,
                readingMinutes: readingMinutes
            )
        }
        .background(Theme.background)
        .toolbar {
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
    }
}

struct StatusBar: View {
    let cursorLine: Int
    let wordCount: Int
    let charCount: Int
    let readingMinutes: Int

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
