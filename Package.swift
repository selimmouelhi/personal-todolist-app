// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "OnTrack",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "OnTrack", targets: ["OnTrack"])
    ],
    targets: [
        .executableTarget(
            name: "OnTrack",
            path: "Sources"
        )
    ]
)
