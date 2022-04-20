import Foundation

// swiftlint:disable identifier_name

public struct VKVINDecoder {
    public struct Result: Codable {
        // Generate with this JS:
        // console.log(
        //   Object.keys(
        //     (
        //       await (
        //         await fetch(
        //           "https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues/3MW5U7J09N8C40580?format=json"
        //         )
        //       ).json()
        //     ).Results[0]
        //   )
        //     .map((x) => `public let ${x}: String?`)
        //     .join("\n")
        // );

        public let ABS: String?
        public let ActiveSafetySysNote: String?
        public let AdaptiveCruiseControl: String?
        public let AdaptiveDrivingBeam: String?
        public let AdaptiveHeadlights: String?
        public let AdditionalErrorText: String?
        public let AirBagLocCurtain: String?
        public let AirBagLocFront: String?
        public let AirBagLocKnee: String?
        public let AirBagLocSeatCushion: String?
        public let AirBagLocSide: String?
        public let AutoReverseSystem: String?
        public let AutomaticPedestrianAlertingSound: String?
        public let AxleConfiguration: String?
        public let Axles: String?
        public let BasePrice: String?
        public let BatteryA: String?
        public let BatteryA_to: String?
        public let BatteryCells: String?
        public let BatteryInfo: String?
        public let BatteryKWh: String?
        public let BatteryKWh_to: String?
        public let BatteryModules: String?
        public let BatteryPacks: String?
        public let BatteryType: String?
        public let BatteryV: String?
        public let BatteryV_to: String?
        public let BedLengthIN: String?
        public let BedType: String?
        public let BlindSpotIntervention: String?
        public let BlindSpotMon: String?
        public let BodyCabType: String?
        public let BodyClass: String?
        public let BrakeSystemDesc: String?
        public let BrakeSystemType: String?
        public let BusFloorConfigType: String?
        public let BusLength: String?
        public let BusType: String?
        public let CAN_AACN: String?
        public let CIB: String?
        public let CashForClunkers: String?
        public let ChargerLevel: String?
        public let ChargerPowerKW: String?
        public let CoolingType: String?
        public let CurbWeightLB: String?
        public let CustomMotorcycleType: String?
        public let DaytimeRunningLight: String?
        public let DestinationMarket: String?
        public let DisplacementCC: String?
        public let DisplacementCI: String?
        public let DisplacementL: String?
        public let Doors: String?
        public let DriveType: String?
        public let DriverAssist: String?
        public let DynamicBrakeSupport: String?
        public let EDR: String?
        public let ESC: String?
        public let EVDriveUnit: String?
        public let ElectrificationLevel: String?
        public let EngineConfiguration: String?
        public let EngineCycles: String?
        public let EngineCylinders: String?
        public let EngineHP: String?
        public let EngineHP_to: String?
        public let EngineKW: String?
        public let EngineManufacturer: String?
        public let EngineModel: String?
        public let EntertainmentSystem: String?
        public let ErrorCode: String?
        public let ErrorText: String?
        public let ForwardCollisionWarning: String?
        public let FuelInjectionType: String?
        public let FuelTypePrimary: String?
        public let FuelTypeSecondary: String?
        public let GCWR: String?
        public let GCWR_to: String?
        public let GVWR: String?
        public let GVWR_to: String?
        public let KeylessIgnition: String?
        public let LaneCenteringAssistance: String?
        public let LaneDepartureWarning: String?
        public let LaneKeepSystem: String?
        public let LowerBeamHeadlampLightSource: String?
        public let Make: String?
        public let MakeID: String?
        public let Manufacturer: String?
        public let ManufacturerId: String?
        public let Model: String?
        public let ModelID: String?
        public let ModelYear: String?
        public let MotorcycleChassisType: String?
        public let MotorcycleSuspensionType: String?
        public let NCSABodyType: String?
        public let NCSAMake: String?
        public let NCSAMapExcApprovedBy: String?
        public let NCSAMapExcApprovedOn: String?
        public let NCSAMappingException: String?
        public let NCSAModel: String?
        public let NCSANote: String?
        public let NonLandUse: String?
        public let Note: String?
        public let OtherBusInfo: String?
        public let OtherEngineInfo: String?
        public let OtherMotorcycleInfo: String?
        public let OtherRestraintSystemInfo: String?
        public let OtherTrailerInfo: String?
        public let ParkAssist: String?
        public let PedestrianAutomaticEmergencyBraking: String?
        public let PlantCity: String?
        public let PlantCompanyName: String?
        public let PlantCountry: String?
        public let PlantState: String?
        public let PossibleValues: String?
        public let Pretensioner: String?
        public let RearAutomaticEmergencyBraking: String?
        public let RearCrossTrafficAlert: String?
        public let RearVisibilitySystem: String?
        public let SAEAutomationLevel: String?
        public let SAEAutomationLevel_to: String?
        public let SeatBeltsAll: String?
        public let SeatRows: String?
        public let Seats: String?
        public let SemiautomaticHeadlampBeamSwitching: String?
        public let Series: String?
        public let Series2: String?
        public let SteeringLocation: String?
        public let SuggestedVIN: String?
        public let TPMS: String?
        public let TopSpeedMPH: String?
        public let TrackWidth: String?
        public let TractionControl: String?
        public let TrailerBodyType: String?
        public let TrailerLength: String?
        public let TrailerType: String?
        public let TransmissionSpeeds: String?
        public let TransmissionStyle: String?
        public let Trim: String?
        public let Trim2: String?
        public let Turbo: String?
        public let VIN: String?
        public let ValveTrainDesign: String?
        public let VehicleType: String?
        public let WheelBaseLong: String?
        public let WheelBaseShort: String?
        public let WheelBaseType: String?
        public let WheelSizeFront: String?
        public let WheelSizeRear: String?
        public let Wheels: String?
        public let Windows: String?
    }

    struct Response: Codable {
        let Count: Int
        let Message: String
        let SearchCriteria: String
        let Results: [Result]
    }

    public enum DecodeError: Error {
        case missingResult
    }

    public static func decode(vin: String) async throws -> Result {
        let url = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues/\(vin)?format=json"
        let response: Response = try await VKHTTP.request(url).data
        guard let result = response.Results.first else { throw DecodeError.missingResult }
        return result
    }
}
