// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BakingRecipeCells",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BakingRecipeCells",
            targets: ["BakingRecipeCells"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        //.package(name: "BakingRecipeItems", path: "/Users/moritzschaub/Developer/Swift/ios/BrotApp2/BakingRecipeItems"),
        .package(name: "BakingRecipeFoundation", path: "/Users/moritzschaub/Developer/Swift/ios/BrotApp2/BakingRecipeFoundation"),
        .package(name: "BakingRecipeUIFoundation", path: "/Users/moritzschaub/Developer/Swift/ios/BrotApp2/BakingRecipeUIFoundation"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.2.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BakingRecipeCells",
            dependencies: ["BakingRecipeFoundation", "BakingRecipeUIFoundation", "CombineCocoa"]),
        .testTarget(
            name: "BakingRecipeCellsTests",
            dependencies: ["BakingRecipeCells"]),
    ]
)
