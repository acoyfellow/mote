import AppKit
import WebKit

@MainActor
final class PanelController: NSObject, NSWindowDelegate, WKNavigationDelegate {
    let panel: NSPanel
    let webView: WKWebView
    let bridge: NativeBridge

    override init() {
        let controller = WKUserContentController()
        bridge = NativeBridge()
        controller.add(bridge, name: "mote")
        controller.addUserScript(WKUserScript(
            source: Self.bootstrapScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        ))

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        configuration.websiteDataStore = .default()

        webView = WKWebView(frame: .zero, configuration: configuration)
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 390, height: 820),
            styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        super.init()

        bridge.webView = webView
        webView.navigationDelegate = self
        webView.setValue(false, forKey: "drawsBackground")

        panel.delegate = self
        panel.contentView = webView
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovable = false
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.hasShadow = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
    }

    func toggle(relativeTo statusButton: NSStatusBarButton) {
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            show(relativeTo: statusButton)
        }
    }

    func show(relativeTo statusButton: NSStatusBarButton) {
        guard let buttonWindow = statusButton.window else { return }
        let buttonFrame = buttonWindow.convertToScreen(statusButton.frame)
        let visibleFrame = buttonWindow.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero
        var frame = panel.frame
        frame.origin.x = min(max(buttonFrame.midX - frame.width / 2, visibleFrame.minX + 8), visibleFrame.maxX - frame.width - 8)
        frame.origin.y = buttonFrame.minY - frame.height - 8
        panel.setFrame(frame, display: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func load(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    func showError(_ message: String) {
        let escaped = message
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        webView.loadHTMLString("""
        <!doctype html><meta charset="utf-8"><style>
        :root{color-scheme:dark}body{margin:0;padding:24px;background:#151515;color:#f5f5f5;font:14px -apple-system;line-height:1.5}
        h1{font-size:18px}pre{white-space:pre-wrap;color:#ffb4a9}button{padding:8px 12px;border:0;border-radius:8px}
        </style><h1>Mote could not load the workspace</h1><pre>\(escaped)</pre>
        <p>Edit the workspace or inspect <code>~/Library/Logs/Mote/runtime.log</code>, then relaunch Mote.</p>
        """, baseURL: nil)
    }

    func windowDidResignKey(_ notification: Notification) {
        panel.orderOut(nil)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url else { return .cancel }
        if url.host == "127.0.0.1" || url.scheme == "about" { return .allow }
        if navigationAction.navigationType == .linkActivated {
            NSWorkspace.shared.open(url)
        }
        return .cancel
    }

    private static let bootstrapScript = """
    (() => {
      const pending = new Map();
      window.__moteResolve = (id, result) => {
        const callback = pending.get(id);
        if (!callback) return;
        pending.delete(id);
        clearTimeout(callback.timer);
        result.ok ? callback.resolve(result.value) : callback.reject(new Error(result.error));
      };
      window.mote = Object.freeze({
        invoke(command, arguments = {}) {
          return new Promise((resolve, reject) => {
            const id = crypto.randomUUID();
            const timeout = command === 'maintenance.cleanup' ? 330000 : 25000;
            const timer = setTimeout(() => {
              if (!pending.has(id)) return;
              pending.delete(id);
              reject(new Error(`Native command timed out: ${command}`));
            }, timeout);
            pending.set(id, { resolve, reject, timer });
            window.webkit.messageHandlers.mote.postMessage({ id, command, arguments });
          });
        }
      });
    })();
    """
}
