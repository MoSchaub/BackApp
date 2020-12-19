// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BakingRecipeUIFoundation",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BakingRecipeUIFoundation",
            targets: ["BakingRecipeUIFoundation"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "BakingRecipeFoundation", path: "/Users/moritzschaub/Developer/Swift/ios/BrotApp2/BakingRecipeFoundation"),
        .package(name: "BakingRecipeStrings", path: "/Users/moritzschaub/Developer/Swift/ios/BrotApp2/BakingRecipeStrings")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BakingRecipeUIFoundation",
            dependencies: ["BakingRecipeFoundation", "BakingRecipeStrings"],
            resources: [.process("Resources/Colors.xcassets")]),
        .testTarget(
            name: "BakingRecipeUIFoundationTests",
            dependencies: ["BakingRecipeUIFoundation"]),
    ]
)
