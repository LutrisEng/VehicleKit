import Foundation

public class VKBMWConnectedDriveAPI: VKVehicleAPIBase<VKBMWConnectedDriveAPI.Credentials>, VKVehicleAPI {
    public enum APIError: Error {
        case authenticatingWithoutCredentials
        case cantEncodeRequestBody
        case invalidAuthConfig
        case authResponseInvalid
        case invalidHost
        case responseInvalid
    }

    public struct Credentials: Codable {
        let username: String
        let password: String
    }

    public struct AuthConfig {
        public struct Endpoints {
            let authenticate: String
        }
        let host: String
        let state: String
        let endpoints: Endpoints
        let clientID: String
        let redirectURI: String
        let responseType: String
        let scope: String
    }

    // From https://github.com/jorgenkg/nodejs-connected-drive/blob/master/lib/config/default.ts
    public var authConfig = AuthConfig(
        host: "https://customer.bmwgroup.com",
        state: "eyJtYXJrZXQiOiJubyIsImxhbmd1YWdlIjoibm8iLCJkZXN0aW5hdGlvbiI6ImxhbmRpbmdQYWdlIiwicGFyYW1ldGVycyI6Int9In0",
        endpoints: AuthConfig.Endpoints(authenticate: "/gcdm/oauth/authenticate"),
        clientID: "dbf0a542-ebd1-4ff0-a9a7-55172fbfce35",
        redirectURI: "https://www.bmw-connecteddrive.com/app/static/external-dispatch.html",
        responseType: "token",
        scope: "authenticate_user vehicle_data remote_services"
    )

    private struct Session {
        let expires: Date
        let token: String
    }

    private var session: Session?

    required public override init() {}

    public func beginAuthentication() async -> VKAuthenticationPrompt? {
        if session == nil {
            return .usernamePassword
        } else {
            return nil
        }
    }

    private func authenticate() async throws -> Session {
        if let credentials = credentials {
            let parameters = [
                "client_id": authConfig.clientID,
                "redirect_uri": authConfig.redirectURI,
                "response_type": authConfig.responseType,
                "scope": authConfig.scope,
                "username": credentials.username,
                "password": credentials.password,
                "state": authConfig.state
            ]
            guard let body = VKCommon.encodeURIQuery(parameters: parameters) else {
                throw APIError.cantEncodeRequestBody
            }
            guard let url = URL(string: authConfig.endpoints.authenticate) else {
                throw APIError.invalidAuthConfig
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = body.data(using: .utf8)
            let unknownResponse: URLResponse = try await withCheckedThrowingContinuation {
                continuation in
                URLSession.shared.dataTask(with: request) { _, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let response = response {
                        continuation.resume(returning: response)
                    } else {
                        continuation.resume(throwing: APIError.authResponseInvalid)
                    }
                }
            }
            guard let response = unknownResponse as? HTTPURLResponse else {
                throw APIError.authResponseInvalid
            }
            guard let location = response.value(forHTTPHeaderField: "Location") else {
                throw APIError.authResponseInvalid
            }
            guard let locationComponents = URLComponents(string: location) else {
                throw APIError.authResponseInvalid
            }
            var maybeToken: String? = nil
            var maybeExpires: Date? = nil
            for item in (locationComponents.queryItems ?? []) {
                switch item.name {
                case "access_token":
                    if let token = item.value {
                        maybeToken = token
                    }
                case "expires_in":
                    if let expiresInString = item.value, let expiresIn = Double(expiresInString) {
                        maybeExpires = Date.now.addingTimeInterval(expiresIn)
                    }
                default: break
                }
            }
            guard let token = maybeToken, let expires = maybeExpires else {
                throw APIError.authResponseInvalid
            }
            let session = Session(expires: expires, token: token)
            self.session = session
            return session
        } else {
            throw APIError.authenticatingWithoutCredentials
        }
    }

    private func getSession() async throws -> Session {
        if let session = session {
            if session.expires.timeIntervalSinceReferenceDate - Date.now.timeIntervalSinceReferenceDate < 60 {
                return try await authenticate()
            } else {
                return session
            }
        } else {
            return try await authenticate()
        }
    }

    private func getSession(forceLogin: Bool) async throws -> Session {
        if forceLogin {
            return try await authenticate()
        } else {
            return try await getSession()
        }
    }

    public func finishAuthentication(response: VKAuthenticationResponse) async throws {
        guard case let .usernamePassword(username, password) = response else {
            throw VKError.invalidAuthenticationResponseType(response: response)
        }
        credentials = Credentials(username: username, password: password)
        _ = try await authenticate()
    }

    let host = "https://b2vapi.bmwgroup.com"
    let decoder = JSONDecoder()

    private func request<ResponseType: Codable>(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:],
        forceLogin: Bool = false
    ) async throws -> ResponseType {
        let session = try await getSession()
        guard var url = URLComponents(string: host) else {
            throw APIError.invalidHost
        }
        url.path = path
        var request = URLRequest(url: try url.asURL())
        request.httpMethod = method
        request.setValue("Bearer \(session.token)", forHTTPHeaderField: "Authorization")
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        request.httpBody = body
        let data: Data = try await withCheckedThrowingContinuation {
            continuation in
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: APIError.responseInvalid)
                }
            }
        }
        return try decoder.decode(ResponseType.self, from: data)
    }
}

extension VKBMWConnectedDriveAPI: VKVehiclesAPI {
    private struct VehiclesResultItem: Codable {
        let brand: String?
        let modelName: String?
        let vin: String
        let modelYearNA: String?
    }

    public func allVehicles() async throws -> [VKVehicleData] {
        let path = "/api/me/vehicles/v2?all=true&brand=BM"
        let response: [VehiclesResultItem] = try await request(path: path)
        return response.map { item in
            let year: Int? = {
                if let year = item.modelYearNA {
                    return Int(year)
                } else {
                    return nil
                }
            }()
            return VKVehicleData(
                id: item.vin,
                year: year,
                make: item.brand ?? "BMW/Mini",
                model: item.modelName,
                vin: item.vin
            )
        }
    }
}

extension VKBMWConnectedDriveAPI: VKOdometerAPI {
    private struct TechnicalResponseItem: Codable {
        struct AttributesMap: Codable {
            let mileage: String?
            let unitOfLength: String?
        }
        let attributesMap: AttributesMap
    }

    public func readOdometer(vehicle: String) async throws -> Measurement<UnitLength>? {
        let path = "/api/vehicle/dynamic/v1/\(vehicle)"
        let response: TechnicalResponseItem = try await request(path: path)
        guard let mileageString = response.attributesMap.mileage,
              let mileage = Double(mileageString),
              let unitOfLength = response.attributesMap.unitOfLength
        else { return nil }
        print(unitOfLength)
        return Measurement(value: mileage, unit: .miles)
    }
}