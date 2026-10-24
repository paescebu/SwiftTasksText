> [!WARNING]
> **This repository is deprecated and no longer maintained.** Google now provides official Swift Package Manager support for MediaPipe Tasks. Please migrate to [google-ai-edge/mediapipe](https://github.com/google-ai-edge/mediapipe).

## Why is this deprecated?

SwiftTasksText existed because MediaPipe Tasks had no official Swift Package Manager support. Google now ships that support from [google-ai-edge/mediapipe](https://github.com/google-ai-edge/mediapipe), including the MediaPipeTasksText product. Maintaining a parallel wrapper no longer adds value.

## Migrating to the official package

### Xcode

1. In Xcode, choose **File > Add Package Dependencies…**.
2. Enter `https://github.com/google-ai-edge/mediapipe`. Choose **Up to Next Major Version** or the `master` branch. If you set a minimum version, use **1.1.0** or newer (`v1.0.0` has no package manifest; `v1.1.0` is the first tag that publishes these products).
3. Select the **MediaPipeTasksText** product and add it to your target. **MediaPipeTasksCommon** is included automatically.

### Package.swift

```swift
dependencies: [
    .package(
        url: "https://github.com/google-ai-edge/mediapipe",
        branch: "master"
    ),
],
targets: [
    .target(
        name: "MyAppTarget",
        dependencies: [
            .product(name: "MediaPipeTasksText", package: "mediapipe"),
        ]
    ),
]
```

| This package | Official replacement |
| --- | --- |
| Product `SwiftTasksText` | Product `MediaPipeTasksText` |
| `import MediaPipeTasksText` | `import MediaPipeTasksText` |

**Docs:** [Setup guide for iOS](https://developers.google.com/edge/mediapipe/solutions/setup_ios) · [Text classification for iOS](https://developers.google.com/edge/mediapipe/solutions/text/text_classifier/ios) · [Text embedding for iOS](https://developers.google.com/edge/mediapipe/solutions/text/text_embedder/ios) · [Language detection for iOS](https://developers.google.com/edge/mediapipe/solutions/text/language_detector/ios)

## Thank you

Thank you to everyone who used SwiftTasksText, and to everyone who reported issues or contributed. Existing tags and releases remain available for projects that already depend on them.

---

## Legacy documentation

# SwiftTasksText

**SwiftTasksText** is a Swift package that facilitates the integration of Google's MediaPipe Tasks Text solutions into your iOS applications. By adding this package as a dependency, you can seamlessly access MediaPipe's powerful text classification APIs without the need for CocoaPods.

> **Disclaimer:** This project is an independent endeavor and is **not affiliated with Google**.

## Features

- **Swift Package Integration:** Simplify your project setup by integrating MediaPipe Tasks Text through Swift Package Manager.
- **Example Application:** Includes an adapted version of Google's original example app, showcasing integration via Swift Package Manager instead of CocoaPods.
- **Automatic Package Update:** On a daily basis the package is updated by a GitHub Action (if needed) and tracks the MediaPipe Task Text Pods versioning.

## Installation

To integrate **MediaPipeTasksText** into your Xcode project using this package:

1. **Add Package Dependency:**
   - Open your project in Xcode.
   - Navigate to `File` > `Add Packages...`.
   - Enter the repository URL for SwiftTasksText.
   - Select the desired version and add the package.
   
2. **Import and Use:**
   - In your Swift files, finally import MediaPipeTasksText:
     ```swift
     import MediaPipeTasksText
     ```
   - Utilize MediaPipe's Text APIs as documented.
   
## Example Application

The package includes an adjusted example application (originally from Google) demonstrating use of text classification. This serves as a practical reference for integrating and utilizing the APIs in your projects.

## About MediaPipe Text

[MediaPipe](https://ai.google.dev/edge/mediapipe/solutions/guide) is a cross-platform framework by Google that offers customizable machine learning solutions for live and streaming media.

For detailed information and documentation, refer to the [MediaPipe Tasks Guide](https://ai.google.dev/edge/mediapipe/solutions/tasks).

## License

This project is licensed under the MIT License.

---

*Note: MediaPipe is a trademark of Google. This project is not affiliated with or endorsed by Google.*
