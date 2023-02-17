// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdaEmbedFramework",
    defaultLocalization: .init("en"),
    platforms: [
      .iOS(.v10),
    ],
    products: [
        .library(
            name: "AdaEmbedFramework",
            targets: ["AdaEmbedFramework"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AdaEmbedFramework",
            dependencies: [],
            path: "EmbedFramework",
            exclude: [
              "Info.plist",
            ],
            resources: [
              .process("Assets.xcassets"),
              .process("AdaWebHostViewController.storyboard"),
            ]
        ),
    ]
)
