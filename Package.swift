// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ActivityIndicatorTextView",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ActivityIndicatorTextView",
            targets: ["ActivityIndicatorTextView"]
        ),
        .library(
            name: "UIComponentActivityIndicatorTextView",
            targets: ["UIComponentActivityIndicatorTextView"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/lkzhao/UIComponent.git", .upToNextMajor(from: "3.0.0")),
    ],
    targets: [
        .target(
            name: "ActivityIndicatorTextView"),
        .target(
            name: "UIComponentActivityIndicatorTextView",
            dependencies: [
                "ActivityIndicatorTextView",
                .product(name: "UIComponent", package: "UIComponent"),
            ]
        ),
    ]
)
