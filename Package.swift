// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ZscalerSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ZscalerSDK",
            targets: ["ZscalerSDK"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "ZscalerSDK",
            path: "Zscaler.xcframework"
        ),
    ]
)
