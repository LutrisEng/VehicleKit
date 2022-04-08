import Foundation

public class VKAPIDirectory {
    public struct API {
        let type: VKVehicleAPI.Type
        let name: String
        let makes: Set<String>
    }

    public static let apis = [
        API(type: VKTeslaAPI.self, name: "Tesla", makes: ["Tesla"]),
        API(type: VKBMWConnectedDriveAPI.self, name: "BMW Connected Drive", makes: ["BMW", "Mini"])
    ]
}
