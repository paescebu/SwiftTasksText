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
            checksum: "9264cc581aa9dc792b3083eea010315f30a5aea6be21248f592b474d60597b7b"
        ),
        .binaryTarget(
            name: "MediaPipeCommonLibraries",
            url: "https://github.com/paescebu/SwiftTasksText/releases/download/0.10.21/MediaPipeCommonLibraries.xcframework.zip",
            checksum: "d5902d1ab8af8f0ba61a67e7dabcc7126b4c32c9c5ebd5e36c03dc47c9126bff"
        ),
        .binaryTarget(
            name: "MediaPipeTasksCommon",
            url: "https://github.com/paescebu/SwiftTasksText/releases/download/0.10.21/MediaPipeTasksCommon.xcframework.zip",
            checksum: "583c2edd10a73beb67320bfcabea648761862e88bf6fd72690a40fda4031342d"
        ),
        .executableTarget(
            name: "UpdatePackage",
            resources: [
                .process("Resources/MediaPipeText.Info.plist")
            ]
        )
    ]
)
