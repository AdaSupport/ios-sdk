// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AdaEmbedFramework",
    defaultLocalization: "en",
    products: [
        .library(
            name: "AdaEmbedFramework",
            targets: ["AdaEmbedFramework"]
        ),
    ],
    targets: [
        .target(
            name: "AdaEmbedFramework",
            path: "EmbedFramework"
        )
    ]
)
