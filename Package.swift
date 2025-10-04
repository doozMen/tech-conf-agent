// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "tech-conf-mcp",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "TechConfCore", targets: ["TechConfCore"]),
        .library(name: "TechConfSync", targets: ["TechConfSync"]),
        .executable(name: "tech-conf-mcp", targets: ["TechConfMCP"])
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", branch: "main"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.23.0"),
        .package(url: "https://github.com/pointfreeco/swift-structured-queries", branch: "main")
        // Note: sharing-grdb package has a build error in CustomFunctions.swift
        // The error is: "[QueryBinding] doesn't conform to QueryDecoder"
        // Uncomment when fixed upstream:
        // .package(url: "https://github.com/pointfreeco/sharing-grdb", branch: "main")
    ],
    targets: [
        .target(
            name: "TechConfCore",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "StructuredQueries", package: "swift-structured-queries")
                // Note: StructuredQueriesGRDB removed due to build error in sharing-grdb
                // Uncomment when upstream is fixed:
                // .product(name: "StructuredQueriesGRDB", package: "sharing-grdb")
            ],
            resources: [
                .copy("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "TechConfSync",
            dependencies: [
                "TechConfCore",
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ]
        ),
        .executableTarget(
            name: "TechConfMCP",
            dependencies: [
                "TechConfCore",
                "TechConfSync",
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "TechConfCoreTests",
            dependencies: [
                "TechConfCore",
                "TechConfMCP"
            ]
        )
    ]
)
