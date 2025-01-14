// swift-tools-version:5.2
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import PackageDescription

let package = Package(
    name: "BakingRecipeFoundation",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BakingRecipeFoundation",
            targets: ["BakingRecipeFoundation"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "BakingRecipeStrings", path: "../BakingRecipeStrings"),
        .package(name: "GRDB", url: "https://github.com/groue/GRDB.swift.git", .upToNextMajor(from: "6.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BakingRecipeFoundation",
            dependencies: ["BakingRecipeStrings", "GRDB"]),
        .testTarget(
            name: "BakingRecipeFoundationTests",
            dependencies: ["BakingRecipeFoundation"]),
    ]
)
