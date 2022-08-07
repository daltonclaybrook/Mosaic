// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Mosaic",
	platforms: [
		.macOS(.v11)
	],
	products: [
		.executable(name: "mosaic", targets: ["Mosaic"])
	],
    dependencies: [
    ],
    targets: [
        .executableTarget(name: "Mosaic", dependencies: []),
        .testTarget(name: "MosaicTests", dependencies: ["Mosaic"]),
    ]
)
