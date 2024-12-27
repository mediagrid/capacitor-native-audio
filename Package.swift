// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SoundsCapacitorNativeAudio",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "SoundsCapacitorNativeAudio",
            targets: ["AudioPlayerPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "AudioPlayerPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/AudioPlayerPlugin"),
        .testTarget(
            name: "AudioPlayerPluginTests",
            dependencies: ["AudioPlayerPlugin"],
            path: "ios/Tests/AudioPlayerPluginTests")
    ]
)
