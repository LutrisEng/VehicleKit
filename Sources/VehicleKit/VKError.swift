import Foundation

enum VKError: Error {
    case notAuthenticated
    case invalidVehicle(id: Any)
    case invalidAuthenticationResponseType(response: VKAuthenticationResponse)
}
