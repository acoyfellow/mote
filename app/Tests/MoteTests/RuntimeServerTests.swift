import Foundation
import Testing
@testable import Mote

@Suite(.serialized)
struct RuntimeServerTests {
    @Test @MainActor
    func ownsAndStopsItsRuntimeProcess() async throws {
        let workspace = FileManager.default.temporaryDirectory
            .appendingPathComponent("mote-runtime-tests-\(UUID().uuidString)", isDirectory: true)
        let bin = workspace.appendingPathComponent("node_modules/.bin", isDirectory: true)
        try FileManager.default.createDirectory(at: bin, withIntermediateDirectories: true)
        try "{}".write(to: workspace.appendingPathComponent("package.json"), atomically: true, encoding: .utf8)
        try "<title>Mote</title>".write(to: workspace.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)

        let vite = bin.appendingPathComponent("vite")
        let script = """
        #!/bin/bash
        cd "$(dirname "$0")/../.."
        exec /usr/bin/python3 -m http.server "$4" --bind 127.0.0.1
        """
        try script.write(to: vite, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: vite.path)

        let port = Int.random(in: 43_000...48_000)
        let runtime = RuntimeServer(workspaceURL: workspace, port: port)
        let url = try await runtime.start()
        #expect(url.port == port)

        runtime.stop()
        for _ in 0..<30 {
            if !(await responds(url)) { break }
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(await !responds(url), "runtime child should not survive Mote")
    }

    private func responds(_ url: URL) async -> Bool {
        var request = URLRequest(url: url)
        request.timeoutInterval = 0.2
        return (try? await URLSession.shared.data(for: request)) != nil
    }
}
