// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VehicleKit",
    platforms: [
        .iOS(.v15), .watchOS(.v8), .tvOS(.v15)
    ],
    products: [
        .library(
            name: "VehicleKit",
            targets: ["VehicleKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jonasman/TeslaSwift.git", .upToNextMajor(from: "7.1.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.5.0")),
    ],
    targets: [
        .target(
            name: "VehicleKit",
            dependencies: ["TeslaSwift", "Alamofire"]),
        .testTarget(
            name: "VehicleKitTests",
            dependencies: ["VehicleKit"]),
    ]
)
