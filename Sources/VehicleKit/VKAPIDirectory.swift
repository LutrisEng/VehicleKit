import Foundation

public class VKAPIDirectory {
    public struct API {
        public let type: VKVehicleAPI.Type
        public let name: String
        public let makes: Set<String>

        public func matches(make: String) -> Bool {
            let normalized = make.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            for potentialMatch in makes {
                let normalizedPotentialMatch = potentialMatch
                    .lowercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if normalizedPotentialMatch == normalized {
                    return true
                }
            }
            return false
        }
    }

    public static let apis = [
        API(type: VKTeslaAPI.self, name: "Tesla", makes: ["Tesla"]),
        API(type: VKBMWConnectedDriveAPI.self, name: "BMW Connected Drive", makes: ["BMW", "Mini"])
    ]

    public static func apis(forMake: String) -> [API] {
        apis.filter { api in api.matches(make: forMake) }
    }
}
