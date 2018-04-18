// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SafeScript",
    products: [
        .executable(name: "safescript", targets: ["safescript"]),
        .library(name: "AST", type: .static, targets: ["AST"]),
        .library(name: "Parser", type: .static, targets: ["Parser"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "safescript", dependencies: ["Parser", "Sema"]),
        .target(name: "Parser", dependencies: ["AST"]),
        .target(name: "Sema", dependencies: ["AST", "Utils"]),
        .target(name: "AST"),
        .target(name: "Utils"),
    ]
)
