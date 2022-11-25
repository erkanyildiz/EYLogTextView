// swift-tools-version:5.3

import PackageDescription

let package = Package(

    name: "EYLogTextView",

    platforms: [
        .iOS(.v13)
    ],

    products: [
        .library(
            name: "EYLogTextView",
            targets: ["EYLogTextView"])
    ],

    targets: [
        .target(
            name: "EYLogTextView",
            dependencies: [],
            publicHeadersPath: "",
            linkerSettings: 
            [
                .linkedFramework("UIKit")
            ]),
    ]
)
