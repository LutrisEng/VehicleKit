import XCTest
import VehicleKit

class VKVINDecoderTests: XCTestCase {
    func testBMW() async throws {
        let vin = "3MW5U7J09N8C40580"
        let result = try await VKVINDecoder.decode(vin: vin)
        XCTAssertEqual(result.VIN, vin)
        XCTAssertEqual(result.Make, "BMW")
        XCTAssertEqual(result.Model, "M340i")
        XCTAssertEqual(result.ModelYear, "2022")
        XCTAssertEqual(result.BodyClass, "Sedan/Saloon")
        XCTAssertEqual(result.EngineCylinders, "6")
        XCTAssertEqual(result.Manufacturer, "BMW MANUFACTURER CORPORATION / BMW NORTH AMERICA")
    }
}
