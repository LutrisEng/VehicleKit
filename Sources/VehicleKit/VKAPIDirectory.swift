import Foundation

public class VKAPIDirectory {
    public struct API {
        let type: VKVehicleAPI.Type
        let make: String
    }

    public static let apis = [
        API(type: VKTeslaAPI.self, make: "Tesla"),
        API(type: VKBMWConnectedDriveAPI.self, make: "BMW")
    ]
}
