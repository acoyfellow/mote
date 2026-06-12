import Foundation

struct EmployeeConfig: Decodable, Sendable {
    struct AuthResource: Decodable, Sendable {
        let label: String
        let resourceId: String
        let executable: String
        let cli: String
        let statusArguments: [String]
        let refreshArguments: [String]
    }

    struct Presentation: Decodable, Sendable {
        let machineLabel: String?
        let endpointLabel: String?
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

    static func load() throws -> EmployeeConfig {
        let file = ProcessInfo.processInfo.environment["MOTE_EMPLOYEE_CONFIG"]
            .map { URL(fileURLWithPath: $0) }
            ?? FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".mote/config/employee.json")
        guard FileManager.default.isReadableFile(atPath: file.path) else {
            throw ConfigError.missing(file.path)
        }
        do {
            let data = try Data(contentsOf: file)
            return try JSONDecoder().decode(EmployeeConfig.self, from: data)
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
            "Employee configuration is not installed at \(path)"
        case .invalid(let path, let detail):
            "Employee configuration at \(path) is invalid: \(detail)"
        }
    }
}
