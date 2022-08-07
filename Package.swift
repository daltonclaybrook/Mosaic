// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Mosaic",
	platforms: [
		.macOS(.v11)
	],
    dependencies: [
    ],
    targets: [
        .executableTarget(name: "Mosaic", dependencies: []),
        .testTarget(name: "MosaicTests", dependencies: ["Mosaic"]),
    ]
)
