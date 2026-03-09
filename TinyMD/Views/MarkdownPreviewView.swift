import SwiftUI
import WebKit

struct MarkdownPreviewView: NSViewRepresentable {
    let markdown: String

    private let renderer = MarkdownRenderer()

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        context.coordinator.webView = webView
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let html = renderer.html(from: markdown)

        // Debounce: cancel pending render, schedule a new one
        context.coordinator.pendingRender?.cancel()

        let workItem = DispatchWorkItem { [weak webView] in
            guard let webView = webView else { return }
            // Save scroll position, load HTML, restore scroll position
            webView.evaluateJavaScript("window.scrollY") { result, _ in
                let scrollY = result as? CGFloat ?? 0
                webView.loadHTMLString(html, baseURL: nil)
                // Restore after a brief delay to let the page render
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    webView.evaluateJavaScript("window.scrollTo(0, \(scrollY))")
                }
            }
        }

        context.coordinator.pendingRender = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: workItem)
    }

    class Coordinator {
        weak var webView: WKWebView?
        var pendingRender: DispatchWorkItem?
    }
}
