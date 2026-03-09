import Foundation
import Ink

struct MarkdownRenderer {
    private let parser = MarkdownParser()

    func html(from markdown: String) -> String {
        let body = parser.html(from: markdown)
        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <style>
        \(Self.css)
        </style>
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
    }

    private static let css = """
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
        background: #1a1710;
        color: rgba(220, 200, 170, 0.78);
        font-family: 'Georgia', serif;
        font-size: 15px;
        line-height: 1.78;
        padding: 36px 40px 60px;
        max-width: 680px;
        margin: 0 auto;
        -webkit-font-smoothing: antialiased;
    }
    h1 {
        font-size: 2.1rem;
        font-weight: 400;
        color: rgba(240, 220, 185, 0.95);
        line-height: 1.2;
        margin-bottom: 0.6em;
        letter-spacing: -0.01em;
    }
    h2 {
        font-size: 1.35rem;
        font-weight: 400;
        font-style: italic;
        color: rgba(232, 210, 170, 0.85);
        margin-top: 1.8em;
        margin-bottom: 0.5em;
    }
    h3 {
        font-family: ui-monospace, monospace;
        font-size: 0.75rem;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.12em;
        color: rgba(220, 200, 160, 0.5);
        margin-top: 1.6em;
    }
    p {
        margin-bottom: 1em;
    }
    strong {
        color: rgba(240, 220, 185, 0.95);
        font-weight: 600;
    }
    em {
        color: rgba(220, 200, 170, 0.65);
    }
    code {
        font-family: ui-monospace, monospace;
        font-size: 12px;
        background: rgba(232, 201, 122, 0.08);
        color: rgba(232, 201, 122, 0.85);
        padding: 1px 5px;
        border-radius: 3px;
    }
    pre {
        background: rgba(10, 9, 7, 0.6);
        border: 1px solid rgba(220, 200, 170, 0.08);
        border-radius: 6px;
        padding: 16px 20px;
        overflow-x: auto;
        margin: 1.2em 0;
    }
    pre code {
        background: none;
        padding: 0;
        color: rgba(220, 200, 170, 0.72);
    }
    blockquote {
        border-left: 2px solid rgba(232, 201, 122, 0.3);
        margin: 1.2em 0;
        padding: 0.1em 0 0.1em 1.4em;
        font-style: italic;
        color: rgba(220, 200, 170, 0.55);
    }
    ul, ol {
        padding-left: 1.4em;
        margin-bottom: 1em;
    }
    ul { list-style: none; padding: 0; }
    li {
        padding-left: 1.4em;
        position: relative;
        margin-bottom: 0.2em;
    }
    ul > li::before {
        content: "–";
        position: absolute;
        left: 0;
        color: rgba(232, 201, 122, 0.4);
    }
    hr {
        border: none;
        height: 1px;
        background: rgba(220, 200, 170, 0.1);
        margin: 2em 0;
    }
    a {
        color: rgba(232, 201, 122, 0.8);
        text-decoration: none;
    }
    a:hover {
        text-decoration: underline;
    }
    img {
        max-width: 100%;
        border-radius: 6px;
        margin: 1em 0;
    }
    table {
        width: 100%;
        border-collapse: collapse;
        margin: 1.2em 0;
    }
    th, td {
        text-align: left;
        padding: 8px 12px;
        border-bottom: 1px solid rgba(220, 200, 170, 0.1);
    }
    th {
        color: rgba(220, 200, 160, 0.5);
        font-family: ui-monospace, monospace;
        font-size: 0.75rem;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.08em;
    }
    """
}
