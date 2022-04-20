import XCTest
import VehicleKit

class VKVINDecoderTests: XCTestCase {
    func testBMW() async throws {
        let result = try await VKVINDecoder.decode(vin: "3MW5U7J09N8C40580")
        XCTAssertEqual(result.errorCode, 0)
        XCTAssertEqual(result.make, "BMW")
        XCTAssertEqual(result.model, "M340i")
        XCTAssertEqual(result.modelYear, 2022)
    }
}
