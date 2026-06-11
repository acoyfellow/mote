// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mote",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "Mote", targets: ["Mote"])],
    targets: [
        .executableTarget(
            name: "Mote",
            path: "Sources/Mote",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("WebKit")
            ]
        ),
        .testTarget(
            name: "MoteTests",
            dependencies: ["Mote"],
            path: "Tests/MoteTests"
        )
    ]
)
