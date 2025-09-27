// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftTasksText",
    platforms: [
        .iOS(.v13),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftTasksText",
            targets: ["SwiftTasksText"]
        ),
        .executable(
            name: "UpdatePackage",
            targets: ["UpdatePackage"]
        )
    ],
    targets: [
        .target(
            name: "SwiftTasksText",
            dependencies: ["SwiftTasksTextCore"]
        ),
        .target(
            name: "SwiftTasksTextCore",
            dependencies: [
                "MediaPipeCommonLibraries",
                "MediaPipeTasksText"
            ],
            linkerSettings: [
                .unsafeFlags(["-ObjC"])
            ]
        ),
        .binaryTarget(
            name: "MediaPipeTasksText",
            url: "https://github.com/paescebu/SwiftTasksText/releases/download/0.10.21/MediaPipeTasksText.xcframework.zip",
            checksum: "375c8206a11d29e4efe89fb916c828caac8035beb4a81cee15eacc5ffad98c6c"
        ),
        .binaryTarget(
            name: "MediaPipeCommonLibraries",
            url: "https://github.com/paescebu/SwiftTasksText/releases/download/0.10.21/MediaPipeCommonLibraries.xcframework.zip",
            checksum: "da6f15ad04a42c002b91d72cb470b609c6f54267b5fbf581da13d36385f6d372"
        ),
        .binaryTarget(
            name: "MediaPipeTasksCommon",
            url: "https://github.com/paescebu/SwiftTasksText/releases/download/0.10.21/MediaPipeTasksCommon.xcframework.zip",
            checksum: "68fd3ed1f88fd981e2d16044c2ffe645d315bfcaa8f3c990a2a4b34fab771060"
        ),
        .executableTarget(
            name: "UpdatePackage",
            resources: [
                .process("Resources/MediaPipeText.Info.plist")
            ]
        )
    ]
)
