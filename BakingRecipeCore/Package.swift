// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

struct Strings {
    static var packageName = "BakingRecipeCore"
    static var libraryName = "BakingRecipeCore"
    static var bakingRecipeCoreTargetName = "BakingRecipeCore"
    static var bakingRecipeCoreTestTargetName = "BakingRecipeCoreTests"
    
    static var bakingRecipeFoundationName = "BakingRecipeFoundation"
    static var bakingRecipeFoundationUrl = "/Users/moritzschaub/Developer/Swift/ios/BrotApp2/BakingRecipeFoundation"
}

let package = Package(
    name: Strings.packageName,
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: Strings.libraryName,
            targets: [Strings.bakingRecipeCoreTargetName]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: Strings.bakingRecipeFoundationName, path: Strings.bakingRecipeFoundationUrl),
        .package(name: "BakingRecipeStrings", path: "/Users/moritzschaub/Developer/Swift/ios/BakingRecipeStrings"),
        .package(name: "BakingRecipeItems", path: "/Users/moritzschaub/Developer/Swift/ios/BakingRecipeItems")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: Strings.bakingRecipeCoreTargetName,
            dependencies: ["BakingRecipeFoundation", "BakingRecipeStrings", "BakingRecipeItems"]),
        .testTarget(
            name: Strings.bakingRecipeCoreTestTargetName,
            dependencies: ["BakingRecipeCore"]),
    ]
)
