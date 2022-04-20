import SwiftUI
import TeslaSwift

public class VKTeslaAPI: VKVehicleAPIBase<AuthToken>, VKVehicleAPI {
    #if canImport(WebKit) && canImport(UIKit)
    struct AuthenticationView: UIViewControllerRepresentable {
        let authViewController: TeslaWebLoginViewController

        func makeUIViewController(context: Context) -> TeslaWebLoginViewController {
            authViewController
        }

        func updateUIViewController(_ uiViewController: TeslaWebLoginViewController, context: Context) {
            // NOOP
        }

        var vkView: VKView {
            VKView(type: .teslaAuthenticationView(view: self))
        }
    }
    #endif

    public enum AuthError: Error {
        case notYetImplemented
        case notSupportedOnMacOS
    }

    private let api = TeslaSwift()
    private var authError: Error?

    required public override init() {}

    public func beginAuthentication() async -> VKAuthenticationPrompt? {
        #if canImport(WebKit) && canImport(UIKit)
        // if let credentials = credentials {
        //     api.reuse(token: credentials)
        //     return nil
        // }
        // guard let authViewController = api.authenticateWeb(completion: { result in
        //     switch result {
        //     case .success(let token):
        //         self.credentials = token
        //         self.authError = nil
        //     case .failure(let error):
        //         self.authError = error
        //     }
        // }) else { return nil }
        // return .view(view: AuthenticationView(authViewController: authViewController).vkView)
        authError = AuthError.notYetImplemented
        return nil
        #else
        authError = AuthError.notSupportedOnMacOS
        return nil
        #endif
    }

    public func finishAuthentication(response: VKAuthenticationResponse) async throws {
        if let authError = authError {
            throw authError
        } else if !api.isAuthenticated {
            throw VKError.notAuthenticated
        }
    }

    private func getVehicles() async throws -> [Vehicle] {
        try await withCheckedThrowingContinuation { continuation in
            api.getVehicles { result in
                switch result {
                case .success(let vehicles): continuation.resume(returning: vehicles)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }

    private func getVehicle(id: String) async throws -> Vehicle {
        try await withCheckedThrowingContinuation { continuation in
            api.getVehicle(id) { result in
                switch result {
                case .success(let vehicle): continuation.resume(returning: vehicle)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }

    private func getVehicleState(vehicle: Vehicle) async throws -> VehicleState {
        try await withCheckedThrowingContinuation { continuation in
            api.getVehicleState(vehicle) { result in
                switch result {
                case .success(let vehicle): continuation.resume(returning: vehicle)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension VKTeslaAPI: VKVehiclesAPI {
    public func allVehicles() async throws -> [VKVehicleData] {
        let vehicles = try await getVehicles()
        return vehicles.map { vehicle in
            VKVehicleData(
                id: vehicle.id ?? "",
                year: nil,
                make: "Tesla",
                model: nil,
                vin: vehicle.vin
            )
        }
    }
}

extension VKTeslaAPI: VKOdometerAPI {
    public func readOdometer(vehicle id: String) async throws -> Measurement<UnitLength>? {
        let vehicle = try await getVehicle(id: id)
        let vehicleState = try await getVehicleState(vehicle: vehicle)
        guard let miles = vehicleState.odometer else { return nil }
        return Measurement(value: miles, unit: UnitLength.miles)
    }
}
