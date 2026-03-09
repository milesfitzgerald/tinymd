# Tiny.md

A minimal, native macOS markdown editor with live previe
<img width="887" height="607" alt="Screenshot 2026-03-09 at 9 29 17 PM" src="https://github.com/user-attachments/assets/39a3853a-4664-4848-8daa-31b38ea81803" />



## About

Tiny.md is a distraction-free markdown editor built with SwiftUI and AppKit. Write in raw markdown on the left, see a beautifully rendered preview on the right. No electron. No bloat. Just markdown.

## Features

- **Split View** — Editor, preview, or both side by side
- **Live Preview** — Rendered HTML updates as you type with debounced refresh
- **Warm Dark Theme** — Easy on the eyes with amber accents and Georgia serif preview
- **Native macOS** — Document-based architecture with autosave, version history, and iCloud support
- **Tables, HTML, Collapsible Sections** — Full markdown support via the Ink parser
- **Status Bar** — Line number, word count, character count, reading time
- **Keyboard-Driven** — `⌘⇧1` Editor / `⌘⇧2` Split / `⌘⇧3` Preview

## Install

Requires macOS 13.0+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
git clone https://github.com/milesfitzgerald/tinymd.git
cd tinymd
xcodegen generate
open TinyMD.xcodeproj
```

Build and run with `⌘R` in Xcode, or from the command line:

```bash
xcodebuild -project TinyMD.xcodeproj -scheme TinyMD -configuration Debug build
```

## Project Structure

```
TinyMD/
├── TinyMDApp.swift              # App entry point, DocumentGroup
├── Info.plist                   # UTI declarations for .md files
├── Models/
│   └── MarkdownDocument.swift   # FileDocument for reading/writing markdown
├── Views/
│   ├── ContentView.swift        # Split view layout + status bar
│   ├── MarkdownEditorView.swift # NSTextView wrapper
│   ├── MarkdownPreviewView.swift# WKWebView wrapper
│   └── AppCommands.swift        # Menu bar keyboard shortcuts
└── Services/
    ├── MarkdownRenderer.swift   # Ink parser + HTML/CSS template
    └── Theme.swift              # Colors, fonts, spacing
```

## Dependencies

- [Ink](https://github.com/johnsundell/ink) — Lightweight Swift markdown parser

## License

MIT
