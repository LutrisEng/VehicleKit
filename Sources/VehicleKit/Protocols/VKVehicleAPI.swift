import Foundation

public class VKVehicleAPIBase<Credentials: Codable> {
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    public var credentialKey: String = "default"
    public var credentialStore: VKCredentialStore?
    // In case the credential store or JSON encoding isn't working
    private var cachedCredentials: Credentials?
    public var credentials: Credentials? {
        get {
            if let cachedCredentials = cachedCredentials {
                return cachedCredentials
            } else if let data = credentialStore?.read(key: credentialKey),
                let credentials = try? jsonDecoder.decode(Credentials.self, from: data) {
                cachedCredentials = credentials
                return credentials
            } else {
                return nil
            }
        }
        set {
            if let credentialStore = credentialStore,
               let data = try? jsonEncoder.encode(newValue) {
                credentialStore.write(key: credentialKey, value: data)
            } else {
                cachedCredentials = newValue
            }
        }
    }
}

public protocol VKVehicleAPI {
    init()
    func beginAuthentication() async throws -> VKAuthenticationPrompt?
    func finishAuthentication(response: VKAuthenticationResponse) async throws
}
