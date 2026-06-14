import Foundation
import Testing
@testable import Mote

@Suite(.serialized)
struct NativeBridgeTests {
    let directory: URL

    init() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("mote-bridge-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for name in ["machinectl-daemon.sh", "reachability-mode.sh", "maintenance.sh"] {
            let script = directory.appendingPathComponent(name)
            let contents = """
            #!/bin/bash
            printf '%s' "$0 $*"
            """
            try contents.write(to: script, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: script.path)
        }
        let authCli = directory.appendingPathComponent("auth-cli.sh")
        let authCliContents = """
        #!/bin/bash
        printf '%s' '{"resources":[{"id":"configured-auth","state":"refreshable","expiresAt":"2026-06-11T20:00:00.000Z"}]}'
        """
        try authCliContents.write(to: authCli, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: authCli.path)
        let config = directory.appendingPathComponent("custom.json")
        try JSONSerialization.data(withJSONObject: [
            "authResource": [
                "label": "Configured auth",
                "resourceId": "configured-auth",
                "executable": "/bin/bash",
                "cli": authCli.path,
                "statusArguments": ["status"],
                "refreshArguments": ["refresh"],
                "recoverArguments": ["recover", "configured-auth", "--run"]
            ]
        ]).write(to: config)
        setenv("MOTE_SCRIPT_DIRECTORY", directory.path, 1)
        setenv("MOTE_CUSTOM_CONFIG", config.path, 1)
    }

    @Test @MainActor
    func everySurfaceCommandReturns() async throws {
        let bridge = NativeBridge()
        let cases: [(String, [String: Any], String)] = [
            ("machinectl.status", [:], "status"),
            ("machinectl.action", ["action": "start", "mode": "core"], "start core"),
            ("machinectl.action", ["action": "restart", "mode": "pi"], "restart pi"),
            ("machinectl.action", ["action": "stop"], "stop"),
            ("reachability.status", [:], "status"),
            ("reachability.action", ["action": "start", "seconds": 3600], "start 3600 0"),
            ("reachability.action", ["action": "stop"], "stop"),
            ("maintenance.report", [:], "report"),
            ("maintenance.cleanup", [:], "cleanup")
        ]

        for (command, arguments, expected) in cases {
            let result = await bridge.execute(command: command, arguments: arguments)
            #expect(result.object["ok"] as? Bool == true, "\(command) should succeed")
            let value = try #require(result.object["value"] as? [String: Any])
            let output = try #require(value["output"] as? String)
            #expect(output.hasSuffix(expected), "\(command) returned \(output)")
        }
    }

    @Test @MainActor
    func appConfigurationReportsConfiguredState() async throws {
        let bridge = NativeBridge()
        let result = await bridge.execute(command: "app.configuration", arguments: [:])
        #expect(result.object["ok"] as? Bool == true)
        let value = try #require(result.object["value"] as? [String: Any])
        #expect(value["customConfigured"] as? Bool == true)
        #expect(value["machineLabel"] as? String == "Local service")
        #expect(value["endpointLabel"] as? String == "Optional route")
    }

    @Test @MainActor
    func configuredAuthStatusAndRefreshReturnSecretFreeMetadata() async throws {
        let bridge = NativeBridge()
        for command in ["authResource.status", "authResource.refresh", "authResource.recover"] {
            let result = await bridge.execute(command: command, arguments: [:])
            #expect(result.object["ok"] as? Bool == true)
            let value = try #require(result.object["value"] as? [String: Any])
            let output = try #require(value["output"] as? String)
            #expect(output.contains("configured-auth"))
            #expect(output.contains("refreshable"))
            #expect(!output.localizedCaseInsensitiveContains("token\":"))
        }
    }

    @Test @MainActor
    func invalidCommandsFailClosed() async {
        let bridge = NativeBridge()
        let unknown = await bridge.execute(command: "shell.anything", arguments: [:])
        #expect(unknown.object["ok"] as? Bool == false)

        let invalidAction = await bridge.execute(
            command: "machinectl.action",
            arguments: ["action": "delete", "mode": "core"]
        )
        #expect(invalidAction.object["ok"] as? Bool == false)

        let invalidMode = await bridge.execute(
            command: "machinectl.action",
            arguments: ["action": "start", "mode": "danger"]
        )
        #expect(invalidMode.object["ok"] as? Bool == false)
    }
}
