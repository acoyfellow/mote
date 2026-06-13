import AppKit
import Darwin
import Foundation
import WebKit

@MainActor
final class NativeBridge: NSObject, WKScriptMessageHandler {
    weak var webView: WKWebView?
    private var coordinatorToken: (value: String, expiresAt: Date)?
    private var coordinatorTokenTask: Task<String, Error>?

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            let body = message.body as? [String: Any],
            let id = body["id"] as? String,
            let command = body["command"] as? String
        else { return }

        let arguments = body["arguments"] as? [String: Any] ?? [:]
        Task {
            let result = await execute(command: command, arguments: arguments)
            reply(id: id, result: result)
        }
    }

    func execute(command: String, arguments: [String: Any]) async -> BridgeResult {
        switch command {
        case "app.info":
            return .success([
                "name": "Mote",
                "version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev",
                "workspace": ProcessInfo.processInfo.environment["MOTE_WORKSPACE"] ?? "workspace"
            ])
        case "app.configuration":
            do {
                let config = try CustomConfig.load()
                return .success([
                    "machineLabel": config.presentation?.machineLabel ?? "Local machine",
                    "endpointLabel": config.presentation?.endpointLabel ?? "Private endpoint"
                ])
            } catch {
                return .success(["machineLabel": "Local machine", "endpointLabel": "Private endpoint"])
            }
        case "app.openWorkspace":
            let path = WorkspaceLocator.resolve().path
            NSWorkspace.shared.open(URL(fileURLWithPath: path))
            return .success(["opened": path])
        case "app.openLogs":
            let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Logs/Mote").path
            NSWorkspace.shared.open(URL(fileURLWithPath: path))
            return .success(["opened": path])
        case "machinectl.status":
            return await runScript(name: "machinectl-daemon.sh", arguments: ["status"])
        case "machinectl.action":
            guard let action = arguments["action"] as? String, ["start", "stop", "restart"].contains(action) else {
                return .failure("Expected machinectl action start, stop, or restart")
            }
            let mode = arguments["mode"] as? String ?? "core"
            guard ["core", "pi"].contains(mode) else { return .failure("Unknown machinectl mode") }
            return await runScript(name: "machinectl-daemon.sh", arguments: action == "stop" ? [action] : [action, mode])
        case "reachability.status":
            return await runScript(name: "reachability-mode.sh", arguments: ["status"])
        case "reachability.action":
            guard let action = arguments["action"] as? String, ["start", "stop"].contains(action) else {
                return .failure("Expected reachability action start or stop")
            }
            if action == "stop" { return await runScript(name: "reachability-mode.sh", arguments: ["stop"]) }
            let seconds = max(0, min(arguments["seconds"] as? Int ?? 0, 86_400))
            return await runScript(name: "reachability-mode.sh", arguments: ["start", String(seconds), "0"])
        case "maintenance.report":
            return await runScript(name: "maintenance.sh", arguments: ["report"])
        case "maintenance.cleanup":
            return await runScript(name: "maintenance.sh", arguments: ["cleanup"])
        case "authResource.status":
            return await runAuthResource(refresh: false)
        case "authResource.refresh":
            return await runAuthResource(refresh: true)
        case "remoteCoordinator.overview":
            return await remoteCoordinatorOverview()
        case "remoteCoordinator.acknowledge":
            guard let id = arguments["id"] as? String, !id.isEmpty else { return .failure("Attention id is required") }
            return await remoteCoordinatorRequest(operation: .acknowledge, method: "POST", body: ["ids": [id]])
        case "remoteCoordinator.steer":
            guard let sessionId = arguments["sessionId"] as? String, !sessionId.isEmpty,
                  let content = arguments["content"] as? String, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { return .failure("Session and steering message are required") }
            return await remoteCoordinatorRequest(operation: .inject(sessionId), method: "POST", body: ["content": content])
        case "remoteCoordinator.open":
            do {
                let config = try CustomConfig.load().remoteCoordinator
                guard let config, let url = URL(string: config.baseURL) else { return .failure("Remote coordinator is not configured") }
                NSWorkspace.shared.open(url)
                return .success(["opened": true])
            } catch { return .failure(error.localizedDescription) }
        default:
            return .failure("Unknown native command: \(command)")
        }
    }

    private func runScript(name: String, arguments: [String]) async -> BridgeResult {
        let scriptDirectory = ProcessInfo.processInfo.environment["MOTE_SCRIPT_DIRECTORY"]
            .map { URL(fileURLWithPath: $0, isDirectory: true) }
            ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".mote/scripts", isDirectory: true)
        let timeout: TimeInterval = name == "maintenance.sh" && arguments.first == "cleanup" ? 300 : 20
        return await runCommand(
            executable: scriptDirectory.appendingPathComponent(name),
            arguments: arguments,
            displayName: name,
            timeout: timeout
        )
    }

    private func runAuthResource(refresh: Bool) async -> BridgeResult {
        do {
            let config = try CustomConfig.load().authResource
            let action = refresh
                ? [config.cli] + config.refreshArguments
                : [config.cli] + config.statusArguments
            let result = await runCommand(
                executable: URL(fileURLWithPath: config.executable),
                arguments: action,
                displayName: "configured auth resource",
                timeout: 20
            )
            guard result.object["ok"] as? Bool == true,
                  var value = result.object["value"] as? [String: Any]
            else { return result }
            value["label"] = config.label
            value["resourceId"] = config.resourceId
            return .success(value)
        } catch {
            return .failure(error.localizedDescription)
        }
    }

    private enum CoordinatorOperation {
        case connectorStatus
        case sessions
        case attention
        case acknowledge
        case inject(String)
    }

    private func remoteCoordinatorOverview() async -> BridgeResult {
        async let connector = remoteCoordinatorRequest(operation: .connectorStatus)
        async let sessions = remoteCoordinatorRequest(operation: .sessions)
        async let attention = remoteCoordinatorRequest(operation: .attention)
        let values = await [connector, sessions, attention]
        for result in values where result.object["ok"] as? Bool != true { return result }
        do {
            let config = try CustomConfig.load().remoteCoordinator
            return .success([
                "label": config?.label ?? "Remote activity",
                "connector": (values[0].object["value"] as? [String: Any])?["response"] ?? [:],
                "sessions": (values[1].object["value"] as? [String: Any])?["response"] ?? [:],
                "attention": (values[2].object["value"] as? [String: Any])?["response"] ?? [:]
            ])
        } catch { return .failure(error.localizedDescription) }
    }

    private func remoteCoordinatorRequest(operation: CoordinatorOperation, method: String = "GET", body: [String: Any]? = nil) async -> BridgeResult {
        do {
            guard let config = try CustomConfig.load().remoteCoordinator else { return .failure("Remote coordinator is not configured") }
            let path: String
            switch operation {
            case .connectorStatus: path = config.operations.connectorStatus
            case .sessions: path = config.operations.sessions
            case .attention: path = config.operations.attention
            case .acknowledge: path = config.operations.acknowledgeAttention
            case .inject(let id): path = config.operations.injectSession.replacingOccurrences(of: "{id}", with: id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? id)
            }
            guard let url = URL(string: path, relativeTo: URL(string: config.baseURL))?.absoluteURL else { return .failure("Configured coordinator URL is invalid") }
            let token = try await coordinatorIdentity(config)
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.timeoutInterval = 20
            request.setValue(token, forHTTPHeaderField: "Cf-Access-Token")
            if let body {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                request.setValue("application/json", forHTTPHeaderField: "content-type")
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return .failure("Coordinator request failed")
            }
            let object = try JSONSerialization.jsonObject(with: data)
            Self.log("done configured coordinator request")
            return .success(["response": object])
        } catch { return .failure(error.localizedDescription) }
    }

    private func coordinatorIdentity(_ config: CustomConfig.RemoteCoordinator) async throws -> String {
        if let cached = coordinatorToken, cached.expiresAt > Date() { return cached.value }
        if let running = coordinatorTokenTask { return try await running.value }
        let task = Task<String, Error> {
            let result = await runCommand(
                executable: URL(fileURLWithPath: config.tokenExecutable),
                arguments: config.tokenArguments,
                displayName: "configured coordinator identity",
                timeout: 20
            )
            guard result.object["ok"] as? Bool == true,
                  let token = (result.object["value"] as? [String: Any])?["output"] as? String,
                  !token.isEmpty else { throw CoordinatorError.identity }
            return token
        }
        coordinatorTokenTask = task
        defer { coordinatorTokenTask = nil }
        let token = try await task.value
        coordinatorToken = (token, Date().addingTimeInterval(120))
        return token
    }

    private func runCommand(executable: URL, arguments: [String], displayName: String, timeout: TimeInterval) async -> BridgeResult {
        await Task.detached(priority: .userInitiated) {
            Self.runCommandSynchronously(executable: executable, arguments: arguments, displayName: displayName, timeout: timeout)
        }.value
    }

    nonisolated private static func runCommandSynchronously(executable: URL, arguments: [String], displayName: String, timeout: TimeInterval) -> BridgeResult {
        let startedAt = Date()
        let command = ([displayName] + arguments).joined(separator: " ")
        log("start \(displayName)")
        guard FileManager.default.isExecutableFile(atPath: executable.path) else {
            return .failure("Missing executable: \(executable.path)")
        }

        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = "\(FileManager.default.homeDirectoryForCurrentUser.path)/.bun/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        process.environment = environment

        do {
            try process.run()
            let deadline = Date().addingTimeInterval(timeout)
            while process.isRunning && Date() < deadline {
                Thread.sleep(forTimeInterval: 0.02)
            }
            if process.isRunning {
                process.terminate()
                process.waitUntilExit()
                log("timeout \(command) after \(String(format: "%.2f", Date().timeIntervalSince(startedAt)))s")
                return .failure("Command timed out after \(Int(timeout)) seconds: \(command)")
            }
            let out = String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let err = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard process.terminationStatus == 0 else {
                let message = err.isEmpty ? "Command exited \(process.terminationStatus)" : err
                log("fail \(command): \(message)")
                return .failure(message)
            }
            log("done \(command) in \(String(format: "%.2f", Date().timeIntervalSince(startedAt)))s")
            return .success(["output": out, "exitCode": 0])
        } catch {
            log("error \(command): \(error.localizedDescription)")
            return .failure(error.localizedDescription)
        }
    }

    nonisolated private static func log(_ message: String) {
        let directory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Logs/Mote", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let file = directory.appendingPathComponent("bridge.log")
        let line = "\(ISO8601DateFormatter().string(from: Date())) \(message)\n"
        guard let data = line.data(using: .utf8) else { return }
        let descriptor = Darwin.open(file.path, O_WRONLY | O_CREAT | O_APPEND, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { return }
        defer { Darwin.close(descriptor) }
        data.withUnsafeBytes { bytes in
            guard let base = bytes.baseAddress else { return }
            _ = Darwin.write(descriptor, base, bytes.count)
        }
    }

    private func reply(id: String, result: BridgeResult) {
        guard let data = try? JSONSerialization.data(withJSONObject: result.object),
              let json = String(data: data, encoding: .utf8),
              let idData = try? JSONSerialization.data(withJSONObject: id, options: .fragmentsAllowed),
              let quotedID = String(data: idData, encoding: .utf8)
        else { return }
        webView?.evaluateJavaScript("window.__moteResolve(\(quotedID), \(json))")
    }
}

enum CoordinatorError: LocalizedError {
    case identity
    var errorDescription: String? { "Sign-in needed" }
}

struct BridgeResult: @unchecked Sendable {
    let object: [String: Any]

    static func success(_ value: [String: Any]) -> BridgeResult {
        BridgeResult(object: ["ok": true, "value": value])
    }

    static func failure(_ message: String) -> BridgeResult {
        BridgeResult(object: ["ok": false, "error": message])
    }
}

struct WorkspaceLocator {
    static func resolve() -> URL {
        if let explicit = ProcessInfo.processInfo.environment["MOTE_WORKSPACE"], !explicit.isEmpty {
            return URL(fileURLWithPath: explicit).standardizedFileURL
        }
        let current = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let candidates = [
            current.appendingPathComponent("workspace"),
            current.deletingLastPathComponent().appendingPathComponent("workspace"),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".mote/workspaces/ax")
        ]
        return candidates.first(where: { FileManager.default.fileExists(atPath: $0.appendingPathComponent("package.json").path) }) ?? candidates[0]
    }
}
