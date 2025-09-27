//
//  UpdatePackage.swift
//  SwiftTextTasks
//
//  Created by Pascal Burlet on 27.02.2025.
//

import Foundation
import System

@main
@available(macOS 16.0.0, *)
struct UpdatePackage {
    static let fileManager = FileManager.default

    static func main() async throws {
        try createBuildsFolder()

        downloadPods()
        try moveStaticLibraries()
        try copyMediaPipeTasksTextCommonXCFramework()
        try copyMediaPipeTasksTextXCFramework()
        try copyMediaPipeTasksTextInfoPlist()
        try deletePodsDir()
        try buildCommonXCFramework()
        try copyCommonXCFramework()
        try zipFrameworksForRelease()
        
        let tag = try extractPodVersion()
        let targets = try prepareBinaryTargets(for: tag)
        try updatePackageManifest(with: targets)

        try removeTemporaryFiles()
    }

    private static func createBuildsFolder() throws {
        let buildsFolder = Definitions.packageRoot
            .appending(path: ".Builds")
        if !fileManager.fileExists(atPath: buildsFolder.path) {
            try fileManager.createDirectory(atPath: buildsFolder.path, withIntermediateDirectories: true)
        }
    }

    private static func downloadPods() {
        let podPath = "/usr/local/bin/pod"
        let temporaryDirectory = Definitions.temporaryProjectRoot

        Terminal.runCommand(
            """
            export LANG=en_US.UTF-8;
            \(podPath) install --project-directory=\(temporaryDirectory);
            """
        )
    }

    private static func moveStaticLibraries() throws {
        let staticLibrariesDir = Definitions.temporaryProjectRoot
            .appending(path: "Pods")
            .appending(path: "MediaPipeTasksCommon")
            .appending(path: "frameworks")
            .appending(path: "graph_libraries")

        try fileManager
            .copyContents(
                of: URL(fileURLWithPath: staticLibrariesDir.path),
                to: URL(fileURLWithPath: Definitions.temporaryProjectRoot.path)
            )
    }

    private static func copyMediaPipeTasksTextCommonXCFramework() throws {
        let MediaPipeTasksTextCommonXCFrameworkURL = Definitions.temporaryProjectRoot
            .appending(path: "Pods")
            .appending(path: "MediaPipeTasksCommon")
            .appending(path: "frameworks")
            .appending(path: "MediaPipeTasksCommon.xcframework")
        let temporaryProjectCommonFrameworkURL = Definitions.temporaryProjectRoot
            .appending(path: "MediaPipeTasksCommon.xcframework")
        let buildsFolderCommonFrameworkURL = Definitions.packageRoot
            .appending(path: ".Builds")
            .appending(path: "MediaPipeTasksCommon.xcframework")

        try fileManager
            .copyContents(
                of: URL(fileURLWithPath: MediaPipeTasksTextCommonXCFrameworkURL.path),
                to: URL(fileURLWithPath: temporaryProjectCommonFrameworkURL.path)
            )
        try fileManager
            .copyContents(
                of: URL(fileURLWithPath: MediaPipeTasksTextCommonXCFrameworkURL.path),
                to: URL(fileURLWithPath: buildsFolderCommonFrameworkURL.path)
            )
    }

    private static func copyMediaPipeTasksTextXCFramework() throws {
        let mediaPipeTasksTextXCFrameworkURL = Definitions.temporaryProjectRoot
            .appending(path: "Pods")
            .appending(path: "MediaPipeTasksText")
            .appending(path: "frameworks")
            .appending(path: "MediaPipeTasksText.xcframework")
        let buildsFolderTextFrameworkURL = Definitions.packageRoot
            .appending(path: ".Builds")
            .appending(path: "MediaPipeTasksText.xcframework")

        try fileManager
            .copyContents(
                of: URL(fileURLWithPath: mediaPipeTasksTextXCFrameworkURL.path),
                to: URL(fileURLWithPath: buildsFolderTextFrameworkURL.path)
            )
    }

    private static func copyMediaPipeTasksTextInfoPlist() throws {
        guard let url = Bundle.module.url(forResource: "MediaPipeText.Info", withExtension: "plist") else {
            return
        }
        let data = try Data(contentsOf: url)

        let iOSFrameworkInfoPlist = Definitions.packageRoot
            .appending(path: ".Builds")
            .appending(path: "MediaPipeTasksText.xcframework")
            .appending(path: "ios-arm64")
            .appending(path: "MediaPipeTasksText.framework")
            .appending(path: "Info.plist")

        let simFrameworkInfoPlist = Definitions.packageRoot
            .appending(path: ".Builds")
            .appending(path: "MediaPipeTasksText.xcframework")
            .appending(path: "ios-arm64_x86_64-simulator")
            .appending(path: "MediaPipeTasksText.framework")
            .appending(path: "Info.plist")

        try data.write(to: URL(fileURLWithPath: iOSFrameworkInfoPlist.path))
        try data.write(to: URL(fileURLWithPath: simFrameworkInfoPlist.path))
    }

    private static func deletePodsDir() throws {
        let podsURL = Definitions.temporaryProjectRoot
            .appending(path: "Pods")
        try fileManager.removeItem(at: URL(fileURLWithPath: podsURL.path))
    }

    private static func buildCommonXCFramework() throws {
        let projectFileURL = Definitions.temporaryProjectRoot
            .appending(path: "MediaPipeCommonLibraries.xcodeproj")
        let buildFolder = Definitions.temporaryProjectRoot
            .appending(path: ".Builds")

        let buildiOSFrameworkCommand =
        """
        xcodebuild build \
            -project \(projectFileURL.path) \
            -scheme MediaPipeCommonLibraries \
            -configuration Release \
            -sdk iphoneos \
            BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
            SYMROOT=\(buildFolder)
        """

        let buildSimFrameworkCommand =
        """
        xcodebuild build \
            -project \(projectFileURL.path) \
            -scheme MediaPipeCommonLibraries \
            -configuration Release \
            -sdk iphonesimulator \
            BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
            SYMROOT=\(buildFolder)
        """

        let buildXCFrameworkCommand =
        """
        xcodebuild -create-xcframework \
          -framework \(buildFolder)/Release-iphoneos/MediaPipeCommonLibraries.framework \
          -framework \(buildFolder)/Release-iphonesimulator/MediaPipeCommonLibraries.framework \
          -output \(buildFolder)/MediaPipeCommonLibraries.xcframework
        """

        Terminal.runCommand(buildiOSFrameworkCommand)
        Terminal.runCommand(buildSimFrameworkCommand)
        Terminal.runCommand(buildXCFrameworkCommand)
    }

    private static func copyCommonXCFramework() throws {
        let buildFolder = Definitions.temporaryProjectRoot
        let sourceXCframeworkPath = buildFolder
            .appending(path: ".Builds")
            .appending(path: "MediaPipeCommonLibraries.xcframework")
        let buildsFolderCommonXCFramework = Definitions.packageRoot
            .appending(path: ".Builds")
            .appending(path: "MediaPipeCommonLibraries.xcframework")

        try fileManager.copyContents(
            of: URL(fileURLWithPath: sourceXCframeworkPath.path),
            to: URL(fileURLWithPath: buildsFolderCommonXCFramework.path)
        )
    }

    private static func zipFrameworksForRelease() throws {
        let buildsFolder = Definitions.packageRoot.appending(path: ".Builds")

        let xcframeworks = try fileManager.contentsOfDirectory(atPath: buildsFolder.path)
            .filter { $0.hasSuffix(".xcframework") }

        for xc in xcframeworks {
            let xcPath = buildsFolder.appending(path: xc)
            _ = try fileManager.zipFramework(at: xcPath, buildsFolder: buildsFolder)
        }
    }

    private static func removeTemporaryFiles() throws {
        let CommonStaticLibiOS = Definitions.temporaryProjectRoot
            .appending(path: "libMediaPipeTasksCommon_device_graph.a")
        let CommonStaticLibSim = Definitions.temporaryProjectRoot
            .appending(path: "libMediaPipeTasksCommon_simulator_graph.a")
        let MediaPipeTasksTextCommonXCFramework = Definitions.temporaryProjectRoot
            .appending(path: "MediaPipeTasksCommon.xcframework")

        try fileManager.removeItem(at: URL(fileURLWithPath: CommonStaticLibiOS.path))
        try fileManager.removeItem(at: URL(fileURLWithPath: CommonStaticLibSim.path))
        try fileManager.removeItem(at: URL(fileURLWithPath: MediaPipeTasksTextCommonXCFramework.path))
    }
    
    private static func extractPodVersion() throws -> String {
        let podfileLock = Definitions.temporaryProjectRoot
            .appending(path: "Podfile.lock")
        let contents = try String(contentsOfFile: podfileLock.path)

        // Fallback to regex that matches: MediaPipeTasksText (1.2.3)
        let pattern = "MediaPipeTasksText \\(([0-9A-Za-z.\\-+]+)\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            throw NSError(domain: "UpdatePackage", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid regex"])
        }

        if let match = regex.firstMatch(in: contents, options: [], range: NSRange(contents.startIndex..., in: contents)),
           let range = Range(match.range(at: 1), in: contents) {
            return String(contents[range])
        }

        throw NSError(domain: "UpdatePackage", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse Podfile.lock for MediaPipeTasksText version"])
    }

    private static func prepareBinaryTargets(for tag: String) throws -> [BinaryTarget] {
        let buildsFolder = Definitions.packageRoot.appending(path: ".Builds")
        let xcframeworks = try fileManager.contentsOfDirectory(atPath: buildsFolder.path)
            .filter { $0.hasSuffix(".xcframework") }

        var targets: [BinaryTarget] = []
        for xc in xcframeworks {
            let name = xc.replacingOccurrences(of: ".xcframework", with: "")
            let zipPath = buildsFolder.appending(path: xc + ".zip")
            let url = "https://github.com/paescebu/SwiftTasksText/releases/download/\(tag)/\(xc).zip"
            let checksum = try fileManager.computeChecksum(for: zipPath)
            targets.append(BinaryTarget(name: name, url: url, checksum: checksum))
        }

        return targets
    }

    private static func updatePackageManifest(with targets: [BinaryTarget]) throws {
        let packageSwiftURL = URL(fileURLWithPath: Definitions.packageRoot.appending(path: "Package.swift").path)
        try PackagePatcher.updateBinaryTargets(in: packageSwiftURL, with: targets)
    }
}
