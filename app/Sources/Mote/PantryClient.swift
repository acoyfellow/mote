import Foundation
import Security

struct PantryClient: Sendable {
    private let endpoint = URL(string: "https://pantry.coey.dev/recipes")!
    private let tokenFile: URL

    init(tokenFile: URL? = nil) {
        self.tokenFile = tokenFile ?? FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".terrarium/pantry-token.secret")
    }

    func list(q: String? = nil, capability: String? = nil, scope: String = "owner") async -> BridgeResult {
        guard ["owner", "shared"].contains(scope) else { return .failure("Invalid Pantry scope") }
        guard let token = credential(), !token.isEmpty else {
            return .failure("Pantry credential is not configured")
        }

        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
        var items = [URLQueryItem(name: "scope", value: scope)]
        if let q, !q.isEmpty { items.append(URLQueryItem(name: "q", value: q)) }
        if let capability, !capability.isEmpty { items.append(URLQueryItem(name: "capability", value: capability)) }
        components.queryItems = items

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return .failure("Pantry returned an invalid response") }
            guard (200..<300).contains(http.statusCode) else {
                switch http.statusCode {
                case 401: return .failure("Pantry authentication failed")
                case 503: return .failure("Pantry is not configured")
                default: return .failure("Pantry request failed (HTTP \(http.statusCode))")
                }
            }
            guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let recipes = object["recipes"] as? [[String: Any]] else {
                return .failure("Pantry returned an invalid recipe list")
            }
            let metadata = recipes.compactMap(Self.metadataOnly)
            guard metadata.count == recipes.count else {
                return .failure("Pantry returned invalid recipe metadata")
            }
            return .success(["recipes": metadata, "scope": scope])
        } catch {
            return .failure("Pantry is unavailable")
        }
    }

    // Whitelist the discovery contract at the native boundary. In particular,
    // never forward a server-supplied `code` field or unknown secret-bearing
    // fields into the editable webview.
    static func metadataOnly(_ recipe: [String: Any]) -> [String: Any]? {
        guard let name = recipe["name"] as? String,
              let description = recipe["description"] as? String,
              let inputSchema = recipe["inputSchema"] as? [String: Any],
              let capabilities = recipe["capabilities"] as? [String],
              let status = recipe["status"] as? String,
              let version = recipe["version"] as? Int,
              let visibility = recipe["visibility"] as? String,
              let updatedAt = recipe["updatedAt"] as? String else { return nil }
        var result: [String: Any] = [
            "name": name,
            "description": description,
            "inputSchema": inputSchema,
            "capabilities": capabilities,
            "status": status,
            "version": version,
            "visibility": visibility,
            "updatedAt": updatedAt,
            "sourceRunId": recipe["sourceRunId"] as? String ?? NSNull(),
            "tags": recipe["tags"] as? [String] ?? [],
            "runCount": recipe["runCount"] as? Int ?? 0,
            "lastRunAt": recipe["lastRunAt"] as? String ?? NSNull(),
            "shareCandidate": recipe["shareCandidate"] as? Bool ?? false
        ]
        if let author = recipe["author"] as? String { result["author"] = author }
        return result
    }

    private func credential() -> String? {
        if let value = keychainCredential(), !value.isEmpty { return value }
        guard FileManager.default.isReadableFile(atPath: tokenFile.path),
              let attributes = try? FileManager.default.attributesOfItem(atPath: tokenFile.path),
              let permissions = attributes[.posixPermissions] as? NSNumber,
              permissions.intValue & 0o077 == 0,
              let value = try? String(contentsOf: tokenFile, encoding: .utf8)
        else { return nil }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func keychainCredential() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "coey.dev/pantry",
            kSecAttrAccount as String: NSUserName(),
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8)
        else { return nil }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
