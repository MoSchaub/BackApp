// swift-tools-version:5.3
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later


import PackageDescription

let package = Package(
    name: "BakingRecipeUIFoundation",
    platforms: [SupportedPlatform.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BakingRecipeUIFoundation",
            targets: ["BakingRecipeUIFoundation"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "BakingRecipeFoundation", path: "../BakingRecipeFoundation"),
        .package(name: "BakingRecipeStrings", path: "../BakingRecipeStrings"),
        .package(name: "BackAppCore", path: "../BackAppCore")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BakingRecipeUIFoundation",
            dependencies: ["BakingRecipeFoundation", "BakingRecipeStrings", "BackAppCore"]),
        .testTarget(
            name: "BakingRecipeUIFoundationTests",
            dependencies: ["BakingRecipeUIFoundation"]),
    ]
)
