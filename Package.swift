// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "personal-identification",
    platforms: [
        .macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9),
        .macCatalyst(.v16), .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PersonalIdentification",
            targets: [
                "PersonalIdentification",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-numerics.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.7.0"
        ),
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.33.3"
        ),
        .package(
            url: "https://github.com/apple/swift-crypto.git",
            from: "4.2.0"
        ),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.7.0"),
    ],
    targets: [
        // Foundation of PersonalIdentification
        .target(
            name: "PersonalIdentification",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
        // Executable
        .executableTarget(
            name: "PersonalIdentificationUtility",
            dependencies: [
                "PersonalIdentification",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "BigInt", package: "BigInt"),
            ]
        ),
        // Testing
        .testTarget(
            name: "PersonalIdentificationTests",
            dependencies: [
                "PersonalIdentification"
            ]
        ),
    ]
)
