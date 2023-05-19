// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileMonitor",
    platforms: [
      .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
                name: "FileMonitor",
                targets: ["FileMonitor"]),
        .executable(
                name: "FileMonitorExample",
                targets: ["FileMonitorExample"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FileMonitor",
            dependencies: [
                "FileMonitorShared",
                .target(name: "FileMonitorMacOS", condition: .when(platforms: [.macOS])),
                .target(name: "FileMonitorLinux", condition: .when(platforms: [.linux])),
            ]
        ),
        .target(
            name: "FileMonitorShared",
            path: "Sources/FileMonitorShared"
        ),
        .systemLibrary(name: "CInotify",
                path: "Sources/Inotify"
        ),
        .target(
                name: "FileMonitorLinux",
                dependencies: [
                    .target(name: "CInotify", condition: .when(platforms: [.linux])),
                    "FileMonitorShared"
                ],
                path: "Sources/FileMonitorLinux"
        ),
        .target(
                name: "FileMonitorMacOS",
                dependencies: ["FileMonitorShared"],
                path: "Sources/FileMonitorMacOS"
        ),
        .executableTarget(
                name: "FileMonitorExample",
                dependencies: ["FileMonitor"]),
        .testTarget(
            name: "FileMonitorTests",
            dependencies: ["FileMonitor"]),
    ]
)
