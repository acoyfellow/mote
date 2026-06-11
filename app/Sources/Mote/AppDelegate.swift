import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let panelController = PanelController()
    private var runtime: RuntimeServer!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()

        let workspace = WorkspaceLocator.resolve()
        runtime = RuntimeServer(workspaceURL: workspace)
        Task { [weak self] in
            guard let self else { return }
            do {
                let url = try await self.runtime.start()
                self.panelController.load(url)
                self.statusItem.button?.toolTip = "Mote · \(workspace.lastPathComponent)"
            } catch {
                self.panelController.showError(error.localizedDescription)
                self.statusItem.button?.toolTip = "Mote · runtime error"
                self.statusItem.button?.contentTintColor = .systemRed
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        runtime?.stop()
    }

    private func configureStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Mote")
        button.image?.isTemplate = true
        button.toolTip = "Mote · starting"
        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            statusItem.menu = makeRecoveryMenu()
            sender.performClick(nil)
            statusItem.menu = nil
        } else {
            panelController.toggle(relativeTo: sender)
        }
    }

    private func makeRecoveryMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: "Open Mote", action: #selector(openPanel), keyEquivalent: "")
        menu.addItem(withTitle: "Reload Surface", action: #selector(reloadSurface), keyEquivalent: "r")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Open Workspace", action: #selector(openWorkspace), keyEquivalent: "")
        menu.addItem(withTitle: "Open Logs", action: #selector(openLogs), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Mote", action: #selector(quit), keyEquivalent: "q")
        for item in menu.items { item.target = self }
        return menu
    }

    @objc private func openPanel() {
        guard let button = statusItem.button else { return }
        panelController.show(relativeTo: button)
    }

    @objc private func reloadSurface() {
        panelController.webView.reload()
        openPanel()
    }

    @objc private func openWorkspace() {
        NSWorkspace.shared.open(WorkspaceLocator.resolve())
    }

    @objc private func openLogs() {
        let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Logs/Mote")
        NSWorkspace.shared.open(url)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
