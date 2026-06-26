import Foundation

@MainActor
final class RuntimeServer {
    let workspaceURL: URL
    let port: Int
    private var process: Process?
    private let logURL: URL

    init(workspaceURL: URL, port: Int = 41731) {
        self.workspaceURL = workspaceURL
        self.port = port
        let logs = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/Mote", isDirectory: true)
        try? FileManager.default.createDirectory(at: logs, withIntermediateDirectories: true)
        self.logURL = logs.appendingPathComponent("runtime.log")
    }

    var url: URL { URL(string: "http://127.0.0.1:\(port)")! }

    func start() async throws -> URL {
        if await probe() { return url }
        try launch()
        // Wait up to 30s: cold Node + first-run Vite dependency optimization can
        // exceed the old 8s window, which previously surfaced as "failed to start".
        for _ in 0..<300 {
            if await probe() { return url }
            try await Task.sleep(for: .milliseconds(100))
        }
        throw RuntimeError.startTimedOut(logURL.path)
    }

    /// True when the Vite child process is still alive.
    var childAlive: Bool { process?.isRunning == true }

    /// Idempotent health gate used by the supervisor. Returns true when the
    /// runtime answers on its port. If the child has died (Vite crash, node
    /// breakage) it relaunches it and waits briefly for readiness, so a broken
    /// runtime self-heals instead of leaving the panel stuck on an error page.
    func ensureHealthy() async -> Bool {
        if await probe() { return true }
        if !childAlive {
            stop()
            do { try launch() } catch { return false }
        }
        for _ in 0..<150 {
            if await probe() { return true }
            try? await Task.sleep(for: .milliseconds(100))
        }
        return await probe()
    }

    func stop() {
        process?.terminate()
        process = nil
    }

    private func launch() throws {
        guard FileManager.default.fileExists(atPath: workspaceURL.appendingPathComponent("package.json").path) else {
            throw RuntimeError.missingWorkspace(workspaceURL.path)
        }

        if !FileManager.default.fileExists(atPath: workspaceURL.appendingPathComponent("node_modules").path) {
            let bunCandidates = [
                ProcessInfo.processInfo.environment["MOTE_BUN"],
                FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".bun/bin/bun").path,
                "/opt/homebrew/bin/bun",
                "/usr/local/bin/bun"
            ].compactMap { $0 }
            guard let bun = bunCandidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
                throw RuntimeError.bunNotFound
            }

            let install = Process()
            install.executableURL = URL(fileURLWithPath: bun)
            install.arguments = ["install", "--frozen-lockfile"]
            install.currentDirectoryURL = workspaceURL
            try install.run()
            install.waitUntilExit()
            guard install.terminationStatus == 0 else { throw RuntimeError.installFailed }
        }

        let handle = try FileHandle(forWritingTo: logURL, createIfNeeded: true)
        try handle.seekToEnd()

        // Launch Vite through an explicit Node binary running vite.js directly.
        // Executing the node_modules/.bin/vite shebang script is unreliable on
        // current macOS (Gatekeeper kills the shebang-launched interpreter),
        // while an explicit Node + script path runs cleanly.
        let viteScript = workspaceURL.appendingPathComponent("node_modules/vite/bin/vite.js")
        guard FileManager.default.fileExists(atPath: viteScript.path) else {
            throw RuntimeError.installFailed
        }
        let nodeCandidates = [
            ProcessInfo.processInfo.environment["MOTE_NODE"],
            "/opt/homebrew/bin/node",
            "/usr/local/bin/node",
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".vite-plus/js_runtime/node/24.18.0/bin/node").path,
            "/usr/bin/node"
        ].compactMap { $0 }
        guard let node = nodeCandidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
            throw RuntimeError.bunNotFound
        }

        let child = Process()
        child.executableURL = URL(fileURLWithPath: node)
        child.arguments = [viteScript.path, "--host", "127.0.0.1", "--port", String(port), "--strictPort"]
        child.currentDirectoryURL = workspaceURL
        child.standardOutput = handle
        child.standardError = handle
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = "\(FileManager.default.homeDirectoryForCurrentUser.path)/.bun/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        child.environment = environment
        try child.run()
        process = child
    }

    private func probe() async -> Bool {
        var request = URLRequest(url: url)
        request.timeoutInterval = 0.3
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return false }
            return String(decoding: data, as: UTF8.self).contains("<title>Mote</title>")
        } catch {
            return false
        }
    }
}

enum RuntimeError: LocalizedError {
    case missingWorkspace(String)
    case bunNotFound
    case installFailed
    case startTimedOut(String)

    var errorDescription: String? {
        switch self {
        case .missingWorkspace(let path): "Mote workspace not found at \(path)"
        case .bunNotFound: "Bun was not found. Install Bun or set MOTE_BUN."
        case .installFailed: "Could not install the workspace dependencies."
        case .startTimedOut(let log): "The Svelte runtime did not start. See \(log)"
        }
    }
}

private extension FileHandle {
    convenience init(forWritingTo url: URL, createIfNeeded: Bool) throws {
        if createIfNeeded && !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        try self.init(forWritingTo: url)
    }
}
