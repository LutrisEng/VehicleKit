import Foundation

public struct VKVehicleData {
    let id: String
    let year: Int?
    let make: String?
    let model: String?
    let vin: String?
}

public protocol VKVehiclesAPI: VKVehicleAPI {
    func allVehicles() async throws -> [VKVehicleData]
}
