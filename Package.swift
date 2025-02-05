// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "ATResolve",
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
			name: "ATResolve",
			targets: ["ATResolve"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-async-dns-resolver.git", from: "0.4.0")
	],
	targets: [
		.target(
			name: "ATResolve",
			dependencies: [
				.product(name: "AsyncDNSResolver", package: "swift-async-dns-resolver"),
			]),
		.testTarget(
			name: "ATResolveTests",
			dependencies: ["ATResolve"]
		),
	]
)
