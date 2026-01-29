//
//  UserManagementAPI.swift
//  MrBreathe
//
//  Created by Rohan Perumalil on 1/28/26.
//
import Foundation

// MARK: - Models (match usermanagement.yaml)

struct UserCreateRequest: Codable {
    let email: String
    let password: String
    let first_name: String
    let last_name: String
    let age: Int
    let sex: String                  // "male" or "female"
    let gender_identity: String?
    let height_in: Double
    let weight_lbs: Double
}

struct Profile: Codable {
    let first_name: String
    let last_name: String
    let age: Int
    let sex: String
    let gender_identity: String?
    let height_in: Double
    let weight_lbs: Double
}

struct APIErrorResponse: Codable {
    let detail: String
}

enum UserManagementError: LocalizedError {
    case badStatus(Int, String)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .badStatus(let code, let message):
            return "Request failed (\(code)): \(message)"
        case .transport(let message):
            return message
        }
    }
}

final class UserManagementAPI {
    // ✅ Use tunnel (works on simulator + real iPhone, avoids HTTP/ATS issues)
    private let baseURL = URL(string: "https://mrbreathe.instatunnel.my/usermanagement/api")!

    func ping() async throws -> String {
        let url = baseURL.appendingPathComponent("ping")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw UserManagementError.transport("No HTTP response.")
        }
        guard (200...299).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Service unavailable"
            throw UserManagementError.badStatus(http.statusCode, msg)
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    /// POST /user -> 201 on success
    func createUser(_ user: UserCreateRequest) async throws {
        let url = baseURL.appendingPathComponent("user")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(user)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw UserManagementError.transport("No HTTP response.")
        }

        if http.statusCode == 201 { return }

        let msg = decodeBestErrorMessage(data) ?? (String(data: data, encoding: .utf8) ?? "Unknown error")
        throw UserManagementError.badStatus(http.statusCode, msg)
    }

    /// GET /profile/{email} -> Profile JSON
    func getProfile(email: String) async throws -> Profile {
        let safeEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email
        let url = baseURL
            .appendingPathComponent("profile")
            .appendingPathComponent(safeEmail)

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw UserManagementError.transport("No HTTP response.")
        }

        guard (200...299).contains(http.statusCode) else {
            let msg = decodeBestErrorMessage(data) ?? (String(data: data, encoding: .utf8) ?? "Unknown error")
            throw UserManagementError.badStatus(http.statusCode, msg)
        }

        do {
            return try JSONDecoder().decode(Profile.self, from: data)
        } catch {
            throw UserManagementError.transport("Could not decode profile JSON.")
        }
    }

    /// POST /predict/{email} with JSON array of numbers; returns text/plain diagnosis
    func predict(email: String, breathData: [Double]) async throws -> String {
        let safeEmail = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email
        let url = baseURL
            .appendingPathComponent("predict")
            .appendingPathComponent(safeEmail)

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(breathData)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw UserManagementError.transport("No HTTP response.")
        }

        guard (200...299).contains(http.statusCode) else {
            let msg = decodeBestErrorMessage(data) ?? (String(data: data, encoding: .utf8) ?? "Unknown error")
            throw UserManagementError.badStatus(http.statusCode, msg)
        }

        return String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private func decodeBestErrorMessage(_ data: Data) -> String? {
        if let err = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            return err.detail
        }
        return nil
    }
}
