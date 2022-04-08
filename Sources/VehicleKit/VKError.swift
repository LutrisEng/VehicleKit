import Foundation

public enum VKError: Error {
    case notAuthenticated
    case invalidVehicle(id: Any)
    case invalidAuthenticationResponseType(response: VKAuthenticationResponse)
}
