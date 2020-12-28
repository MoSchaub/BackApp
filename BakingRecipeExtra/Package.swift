// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BackAppExtra",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BackAppExtra",
            targets: ["BackAppExtra"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "BakingRecipeItems", path: "/Users/moritzschaub/Developer/Swift/ios/BrotApp2/BakingRecipeItems"),
        .package(name: "BackAppCore", path: "/Users/moritzschaub/Developer/Swift/ios/BrotApp2/BackAppCore")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BackAppExtra",
            dependencies: ["BakingRecipeItems", "BackAppCore"]),
        .testTarget(
            name: "BackAppExtraTests",
            dependencies: ["BackAppExtra"]),
    ]
)
