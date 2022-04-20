import Foundation

public class VKBMWConnectedDriveAPI: VKVehicleAPIBase<VKBMWConnectedDriveAPI.Credentials>, VKVehicleAPI {
    public enum APIError: Error {
        case authenticatingWithoutCredentials
        case cantEncodeRequestBody
        case invalidAuthConfig
        case authResponseNotHTTP
        case authResponseMissingLocation
        case cantDecodeAuthResponseLocation(location: String)
        case authResponseMissingToken(location: String)
        case authResponseMissingExpires(location: String)
        case invalidHost
        case responseInvalid
        case invalidURL
    }

    public struct Credentials: Codable {
        let username: String
        let password: String
    }

    public struct Endpoints {
        let authenticate: String
    }

    public struct AuthConfig {
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
        state:
            "eyJtYXJrZXQiOiJubyIsImxhbmd1YWdlIjoibm8iLCJkZXN0aW5hdGlvbiI6ImxhbmRpbmdQYWdlIiwicGFyYW1ldGVycyI6Int9In0",
        endpoints: Endpoints(authenticate: "/gcdm/oauth/authenticate"),
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

    private func authenticationParameters(credentials: Credentials) -> [String: String] {
        return [
            "client_id": authConfig.clientID,
            "redirect_uri": authConfig.redirectURI,
            "response_type": authConfig.responseType,
            "scope": authConfig.scope,
            "username": credentials.username,
            "password": credentials.password,
            "state": authConfig.state
        ]
    }

    private func pathToURL(path: String) throws -> URL {
        guard var components = URLComponents(string: host) else {
            throw APIError.invalidHost
        }
        components.path = path
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        return url
    }

    private func authRedirectLocation(credentials: Credentials) async throws -> String {
        let parameters = authenticationParameters(credentials: credentials)
        guard let body = VKCommon.encodeURIQuery(parameters: parameters) else {
            throw APIError.cantEncodeRequestBody
        }
        let url = try pathToURL(path: authConfig.endpoints.authenticate)
        let unknownResponse: URLResponse = try await VKHTTP.rawRequest(
            url,
            method: "POST",
            body: body.data(using: .utf8),
            headers: [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
        ).response
        guard let response = unknownResponse as? HTTPURLResponse else {
            throw APIError.authResponseNotHTTP
        }
        guard let location = response.value(forHTTPHeaderField: "Location") else {
            throw APIError.authResponseMissingLocation
        }
        return location
    }

    private func authenticate() async throws -> Session {
        guard let credentials = credentials else { throw APIError.authenticatingWithoutCredentials }
        let location = try await authRedirectLocation(credentials: credentials)
        guard let locationComponents = URLComponents(string: location) else {
            throw APIError.cantDecodeAuthResponseLocation(location: location)
        }
        var maybeToken: String?
        var maybeExpires: Date?
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
        guard let token = maybeToken else { throw APIError.authResponseMissingToken(location: location) }
        guard let expires = maybeExpires else { throw APIError.authResponseMissingExpires(location: location) }
        let session = Session(expires: expires, token: token)
        self.session = session
        return session
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
        let url = try pathToURL(path: path)
        var allHeaders = headers
        allHeaders["Authorization"] = "Bearer \(session.token)"
        return try await VKHTTP.request(url, method: method, body: body, headers: headers).data
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
    private struct TechnicalResponseAttributesMap: Codable {
        let mileage: String?
        let unitOfLength: String?
    }
    private struct TechnicalResponseItem: Codable {
        let attributesMap: TechnicalResponseAttributesMap
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
