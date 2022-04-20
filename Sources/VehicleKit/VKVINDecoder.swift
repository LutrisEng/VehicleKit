import Foundation

public struct VKVINDecoder {
    struct ResponseResult: Codable {
        let value: String?
        let valueId: String?
        let variable: String?
        let variableId: Int?

        enum CodingKeys: String, CodingKey {
            case value = "Value"
            case valueId = "ValueId"
            case variable = "Variable"
            case variableId = "VariableId"
        }
    }

    struct Response: Codable {
        let count: Int
        let message: String
        let searchCriteria: String
        let results: [ResponseResult]

        enum CodingKeys: String, CodingKey {
            case count = "Count"
            case message = "Message"
            case searchCriteria = "SearchCriteria"
            case results = "Results"
        }

        func toResult() -> Result {
            var result = Result()
            for item in results {
                if let value = item.value {
                    switch item.variableId {
                    case 143: result.errorCode = Int(value) ?? result.errorCode
                    case 26: result.make = value
                    case 28: result.model = value
                    case 29: result.modelYear = Int(value) ?? result.modelYear
                    default: break
                    }
                }
            }
            return result
        }
    }

    public struct Result {
        var errorCode: Int = 0

        var make: String?
        var model: String?
        var modelYear: Int?
    }

    public static func decode(vin: String) async throws -> Result {
        let url = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/\(vin)?format=json"
        let response: Response = try await VKHTTP.request(url)
        return response.toResult()
    }
}
