import Foundation
import Alamofire

struct VINDecoderResponseResult: Codable {
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

struct VINDecoderResponse: Codable {
    let count: Int
    let message: String
    let searchCriteria: String
    let results: [VINDecoderResponseResult]

    enum CodingKeys: String, CodingKey {
        case count = "Count"
        case message = "Message"
        case searchCriteria = "SearchCriteria"
        case results = "Results"
    }

    func toResult() -> VINDecoderResult {
        var result = VINDecoderResult()
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

public struct VINDecoderResult {
    var errorCode: Int = 0

    var make: String?
    var model: String?
    var modelYear: Int?
}

public func decodeVIN(_ vin: String) async throws -> VINDecoderResult {
    let url = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/\(vin)?format=json"
    let response = try await AF.request(url).serializingDecodable(VINDecoderResponse.self).value
    return response.toResult()
}
