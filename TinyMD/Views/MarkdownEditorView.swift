import SwiftUI
import AppKit

struct MarkdownEditorView: NSViewRepresentable {
    @Binding var text: String
    var onCursorChange: ((Int) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = Theme.nsBackground

        let textView = TinyTextView()
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]

        textView.textContainer?.containerSize = NSSize(
            width: scrollView.contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.textContainer?.widthTracksTextView = true

        textView.font = Theme.editorFont
        textView.backgroundColor = Theme.nsBackground
        textView.textColor = Theme.nsText
        textView.insertionPointColor = Theme.nsCaret
        textView.isRichText = false
        textView.allowsUndo = true
        textView.usesFindPanel = true

        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false

        textView.textContainerInset = NSSize(
            width: Theme.editorPadding,
            height: Theme.editorPadding
        )

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = Theme.editorLineHeight
        textView.defaultParagraphStyle = paragraphStyle
        textView.typingAttributes = [
            .font: Theme.editorFont,
            .foregroundColor: Theme.nsText,
            .paragraphStyle: paragraphStyle
        ]

        textView.string = text
        textView.delegate = context.coordinator
        context.coordinator.textView = textView

        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            textView.selectedRanges = selectedRanges
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownEditorView
        weak var textView: NSTextView?

        init(_ parent: MarkdownEditorView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            if parent.text != textView.string {
                parent.text = textView.string
            }
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let location = textView.selectedRange().location
            let upTo = String(textView.string.prefix(location))
            let line = upTo.components(separatedBy: .newlines).count
            parent.onCursorChange?(line)
        }
    }
}

// Subclass to override tab behavior
class TinyTextView: NSTextView {
    override func insertTab(_ sender: Any?) {
        insertText("  ", replacementRange: selectedRange())
    }
}
