// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "BlueskyResolve",
	platforms: [
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
		.visionOS(.v1),
	],
	products: [
		.library(
			name: "BlueskyResolve",
			targets: ["BlueskyResolve"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-async-dns-resolver.git", from: "0.4.0")
	],
	targets: [
		.target(
			name: "BlueskyResolve",
			dependencies: [
				.product(name: "AsyncDNSResolver", package: "swift-async-dns-resolver"),
			]),
		.testTarget(
			name: "BlueskyResolveTests",
			dependencies: ["BlueskyResolve"]
		),
	]
)
