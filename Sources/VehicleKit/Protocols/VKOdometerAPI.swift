import Foundation

public protocol VKOdometerAPI: VKVehicleAPI {
    func readOdometer(vehicle: String) async throws -> Measurement<UnitLength>?
}
