import Foundation
import Testing
@testable import Mote

@Suite(.serialized)
struct RuntimeServerTests {
    @Test @MainActor
    func ownsAndStopsItsRuntimeProcess() async throws {
        let workspace = FileManager.default.temporaryDirectory
            .appendingPathComponent("mote-runtime-tests-\(UUID().uuidString)", isDirectory: true)
        let viteBin = workspace.appendingPathComponent("node_modules/vite/bin", isDirectory: true)
        try FileManager.default.createDirectory(at: viteBin, withIntermediateDirectories: true)
        try "{}".write(to: workspace.appendingPathComponent("package.json"), atomically: true, encoding: .utf8)
        try "<title>Mote</title>".write(to: workspace.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)

        let vite = viteBin.appendingPathComponent("vite.js")
        let script = """
        const http = require("node:http");
        const portIndex = process.argv.indexOf("--port");
        const port = Number(process.argv[portIndex + 1]);
        http.createServer((request, response) => {
          response.writeHead(200, { "content-type": "text/html" });
          response.end("<title>Mote</title>");
        }).listen(port, "127.0.0.1");
        """
        try script.write(to: vite, atomically: true, encoding: .utf8)

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
