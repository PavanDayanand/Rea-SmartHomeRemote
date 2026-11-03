// swift-tools-version: 6.2
import PackageDescription

// This package runs the model/store tests on the Mac without an iOS simulator.
// Open Breeze.xcodeproj to build and learn the actual iPhone app.
let package = Package(
    name: "BreezeCore",
    platforms: [.macOS(.v14)],
    products: [.library(name: "BreezeCore", targets: ["BreezeCore"])],
    targets: [
        .target(name: "BreezeCore", path: "Breeze/Shared", exclude: ["Intents"]),
        .testTarget(name: "BreezeCoreTests", dependencies: ["BreezeCore"], path: "BreezeTests")
    ]
)
