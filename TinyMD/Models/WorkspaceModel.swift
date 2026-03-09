import Foundation
import Combine
import AppKit

struct FileItem: Identifiable, Hashable {
    let id: String
    let url: URL
    let name: String
    let isDirectory: Bool
    var children: [FileItem]?

    var icon: String {
        if isDirectory { return "folder.fill" }
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "md", "markdown": return "doc.text"
        case "txt": return "doc.plaintext"
        default: return "doc"
        }
    }
}

class WorkspaceModel: ObservableObject {
    @Published var rootURL: URL? {
        didSet { persistRoot(); reload() }
    }
    @Published var files: [FileItem] = []
    @Published var currentFileURL: URL?
    @Published var currentText: String = "# Untitled\n\n"
    @Published var isDirty: Bool = false
    @Published var sidebarVisible: Bool = true

    private var fileWatcher: DispatchSourceFileSystemObject?
    private var dirWatcherFD: Int32 = -1
    private var saveWorkItem: DispatchWorkItem?

    private static let rootKey = "workspaceRootPath"
    private static let supportedExtensions: Set<String> = ["md", "markdown", "txt"]

    init() {
        if let path = UserDefaults.standard.string(forKey: Self.rootKey) {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: url.path) {
                self.rootURL = url
                reload()
            }
        }
    }

    deinit {
        stopWatching()
    }

    // MARK: - Directory Picker

    func chooseDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose a folder for your markdown files"
        panel.prompt = "Set as Workspace"

        if panel.runModal() == .OK, let url = panel.url {
            rootURL = url
        }
    }

    // MARK: - File Tree

    func reload() {
        guard let root = rootURL else {
            files = []
            return
        }
        files = buildTree(at: root)
        startWatching()
    }

    private func buildTree(at url: URL) -> [FileItem] {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        var items: [FileItem] = []

        for itemURL in contents.sorted(by: { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }) {
            let isDir = (try? itemURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false

            if isDir {
                let children = buildTree(at: itemURL)
                if !children.isEmpty {
                    items.append(FileItem(
                        id: itemURL.path,
                        url: itemURL,
                        name: itemURL.lastPathComponent,
                        isDirectory: true,
                        children: children
                    ))
                }
            } else if Self.supportedExtensions.contains(itemURL.pathExtension.lowercased()) {
                items.append(FileItem(
                    id: itemURL.path,
                    url: itemURL,
                    name: itemURL.lastPathComponent,
                    isDirectory: false
                ))
            }
        }

        return items
    }

    // MARK: - File Operations

    func openFile(_ url: URL) {
        saveCurrentFile()
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            currentFileURL = url
            currentText = text
            isDirty = false
        } catch {
            // If we can't read it, just show empty
            currentFileURL = url
            currentText = ""
            isDirty = false
        }
    }

    func saveCurrentFile() {
        guard let url = currentFileURL, isDirty else { return }
        do {
            try currentText.write(to: url, atomically: true, encoding: .utf8)
            isDirty = false
        } catch {
            // Save failed silently — could surface in status bar
        }
    }

    func autoSave() {
        saveWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.saveCurrentFile()
        }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: item)
    }

    func createNewFile(name: String = "Untitled.md") {
        guard let root = rootURL else { return }
        var fileURL = root.appendingPathComponent(name)
        let fm = FileManager.default

        // Avoid collision
        var counter = 1
        let baseName = fileURL.deletingPathExtension().lastPathComponent
        let ext = fileURL.pathExtension
        while fm.fileExists(atPath: fileURL.path) {
            fileURL = root.appendingPathComponent("\(baseName) \(counter).\(ext)")
            counter += 1
        }

        let template = "# \(fileURL.deletingPathExtension().lastPathComponent)\n\n"
        do {
            try template.write(to: fileURL, atomically: true, encoding: .utf8)
            reload()
            openFile(fileURL)
        } catch {}
    }

    func renameFile(_ url: URL, to newName: String) {
        let newURL = url.deletingLastPathComponent().appendingPathComponent(newName)
        guard newURL != url else { return }
        do {
            try FileManager.default.moveItem(at: url, to: newURL)
            if currentFileURL == url {
                currentFileURL = newURL
            }
            reload()
        } catch {}
    }

    func deleteFile(_ url: URL) {
        do {
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            if currentFileURL == url {
                currentFileURL = nil
                currentText = "# Untitled\n\n"
                isDirty = false
            }
            reload()
        } catch {}
    }

    // MARK: - Directory Watching

    private func startWatching() {
        stopWatching()
        guard let root = rootURL else { return }

        dirWatcherFD = open(root.path, O_EVTONLY)
        guard dirWatcherFD >= 0 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: dirWatcherFD,
            eventMask: [.write, .rename, .delete],
            queue: .main
        )
        source.setEventHandler { [weak self] in
            self?.reload()
        }
        source.setCancelHandler { [weak self] in
            if let fd = self?.dirWatcherFD, fd >= 0 {
                close(fd)
                self?.dirWatcherFD = -1
            }
        }
        source.resume()
        fileWatcher = source
    }

    private func stopWatching() {
        fileWatcher?.cancel()
        fileWatcher = nil
    }

    // MARK: - Persistence

    private func persistRoot() {
        if let path = rootURL?.path {
            UserDefaults.standard.set(path, forKey: Self.rootKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.rootKey)
        }
    }
}
