import Foundation

struct CustomConfig: Decodable, Sendable {
    struct AuthResource: Decodable, Sendable {
        let label: String
        let resourceId: String
        let executable: String
        let cli: String
        let statusArguments: [String]
        let refreshArguments: [String]
        let recoverArguments: [String]?
        let recoverShellCommand: String?
    }

    struct Presentation: Decodable, Sendable {
        let machineLabel: String?
        let endpointLabel: String?
    }

    struct LoopsYaml: Decodable, Sendable {
        let label: String
        let executable: String
        let configPath: String
    }

    struct Terrarium: Decodable, Sendable {
        let label: String
        let executable: String
        let cwd: String?
    }

    struct RemoteCoordinator: Decodable, Sendable {
        struct Operations: Decodable, Sendable {
            let connectorStatus: String
            let sessions: String
            let attention: String
            let acknowledgeAttention: String
            let injectSession: String
        }

        let label: String
        let baseURL: String
        let tokenExecutable: String
        let tokenArguments: [String]
        let operations: Operations
    }

    let authResource: AuthResource
    let presentation: Presentation?
    let remoteCoordinator: RemoteCoordinator?
    let loopsYaml: LoopsYaml?
    let terrarium: Terrarium?

    static func load() throws -> CustomConfig {
        let file = ProcessInfo.processInfo.environment["MOTE_CUSTOM_CONFIG"]
            .map { URL(fileURLWithPath: $0) }
            ?? FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".mote/config/custom.json")
        guard FileManager.default.isReadableFile(atPath: file.path) else {
            throw ConfigError.missing(file.path)
        }
        do {
            let data = try Data(contentsOf: file)
            return try JSONDecoder().decode(CustomConfig.self, from: data)
        } catch {
            throw ConfigError.invalid(file.path, error.localizedDescription)
        }
    }
}

enum ConfigError: LocalizedError {
    case missing(String)
    case invalid(String, String)

    var errorDescription: String? {
        switch self {
        case .missing(let path):
            "Custom configuration is not installed at \(path)"
        case .invalid(let path, let detail):
            "Custom configuration at \(path) is invalid: \(detail)"
        }
    }
}
