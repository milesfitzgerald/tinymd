import SwiftUI
import AppKit

enum Theme {
    static let background   = Color(red: 0.10, green: 0.09, blue: 0.06)
    static let text         = Color(red: 0.86, green: 0.78, blue: 0.67).opacity(0.85)
    static let accent       = Color(red: 0.91, green: 0.79, blue: 0.48)
    static let border       = Color.white.opacity(0.06)
    static let chrome       = Color(red: 0.055, green: 0.051, blue: 0.039)

    static let nsBackground = NSColor(calibratedRed: 0.10, green: 0.09, blue: 0.06, alpha: 1.0)
    static let nsText       = NSColor(calibratedRed: 0.86, green: 0.78, blue: 0.67, alpha: 0.85)
    static let nsCaret      = NSColor(calibratedRed: 0.91, green: 0.79, blue: 0.48, alpha: 1.0)

    static let editorFont       = NSFont.monospacedSystemFont(ofSize: 13.5, weight: .regular)
    static let editorLineHeight: CGFloat = 1.75
    static let editorPadding: CGFloat = 36

    static let statusFont   = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)
}
