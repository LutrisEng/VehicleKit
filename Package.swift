// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VehicleKit",
    platforms: [
        .iOS(.v15), .watchOS(.v8), .tvOS(.v15), .macCatalyst(.v15), .macOS(.v12)
    ],
    products: [
        .library(
            name: "VehicleKit",
            targets: ["VehicleKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/jonasman/TeslaSwift.git", .upToNextMajor(from: "7.1.0"))
    ],
    targets: [
        .target(
            name: "VehicleKit",
            dependencies: ["TeslaSwift"]),
        .testTarget(
            name: "VehicleKitTests",
            dependencies: ["VehicleKit"])
    ]
)
