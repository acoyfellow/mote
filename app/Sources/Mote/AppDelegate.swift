import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let panelController = PanelController()
    private var runtime: RuntimeServer!
    private var supervisor: Task<Void, Never>?
    private var runtimeHealthy = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()

        let workspace = WorkspaceLocator.resolve()
        runtime = RuntimeServer(workspaceURL: workspace)
        Task { [weak self] in
            guard let self else { return }
            do {
                let url = try await self.runtime.start()
                self.markHealthy(workspace: workspace, url: url)
            } catch {
                // Don't give up: show the error, but let the supervisor keep
                // trying and reload the panel the moment the runtime recovers.
                self.panelController.showError(error.localizedDescription)
                self.statusItem.button?.toolTip = "Mote · starting…"
                self.statusItem.button?.contentTintColor = .systemOrange
            }
            self.startSupervisor(workspace: workspace)
        }
    }

    private func markHealthy(workspace: URL, url: URL) {
        runtimeHealthy = true
        panelController.load(url)
        statusItem.button?.toolTip = "Mote · \(workspace.lastPathComponent)"
        statusItem.button?.contentTintColor = nil
    }

    /// Periodically verifies the Svelte runtime is answering. If the Vite child
    /// crashed or Node briefly broke, RuntimeServer.ensureHealthy() relaunches it;
    /// on any unhealthy→healthy transition we reload the panel so a stale error
    /// page never sticks. This is what makes Mote self-healing.
    private func startSupervisor(workspace: URL) {
        supervisor?.cancel()
        supervisor = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                guard let self else { return }
                let healthy = await self.runtime.ensureHealthy()
                if healthy && !self.runtimeHealthy {
                    self.markHealthy(workspace: workspace, url: self.runtime.url)
                } else if !healthy && self.runtimeHealthy {
                    self.runtimeHealthy = false
                    self.statusItem.button?.toolTip = "Mote · recovering…"
                    self.statusItem.button?.contentTintColor = .systemOrange
                }
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        supervisor?.cancel()
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
